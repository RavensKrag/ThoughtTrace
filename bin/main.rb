#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'gosu'
require 'gl'

require 'DIS'

require 'chipmunk'
require 'require_all'


# Doing it this way obfuscates what is a directory, and what is a file,
# but it makes handling loading files in various directories
# (especially directories that are not children of the current directory)
# much easier to manage and understand.

	# -- file hierarchy --
	# ROOT
	# 	this directory
	# 		this file

# Must expand '..' shortcut into a proper path. But that results in a shorter string.
path_to_root = File.expand_path '../..', __FILE__
full_path = File.join path_to_root, "lib", "PACKAGE_NAME"

Dir.chdir full_path do
	require './utilities/PerformanceTimer'
	
	Metrics::Timer.new "load scripts" do
	
		[
			'./utilities/serialization',
			'./monkey_patches',
			
			'./space',
			
			'./THINGS_TO_DO/actions',
			'./THINGS_TO_DO/input_system',
			
			
			
			'./THINGS_TO_DO_THEM_ON/cameras/camera',
			'./THINGS_TO_DO_THEM_ON/collections/groups/selection',
			
			
			'./utilities/multires_caching/font', # required by entities/text
			'./drawing', # line drawing required by entities/text
			
			'./THINGS_TO_DO_THEM_ON/entities'
		
		
		
		
		].each do |path|
			# if it's a path, require_all
			# if it's a file, require
			# ---------------------------
			if File.directory? path
				# puts "LOAD DIR: #{path}"
				require_all path
			# TODO: Figure out why File.file? doesn't work sans extensions like require
			# elsif File.file? path
			else
				# puts "LOAD FILE: #{path}"
				require path
			end
		end
	
	end
end



module DIS
	def self.timestamp
		Gosu::milliseconds
	end
end

class Window < Gosu::Window
	attr_reader :camera
	attr_reader :space
	attr_reader :input
	
	def initialize(save_path)
		Metrics::Timer.new "setup window" do
			# Necessary to allow access to text input buffers, etc
			# Also allows for easy transformation of vectors through camera
				# (see monkey_patches/Chipmunk/Vec2)
			# Also used for global access of mouse (should probably reconsider this)
			# Allows for loading serialized fonts (can't really pass window there?)
			$window = self
			
			# Setup window
			height = 900
			width = (height.to_f*16/9).to_i
			fullscreen = false
			
			update_interval = 1/60.0 * 1000
			
			super(width, height, fullscreen, update_interval)
			self.caption = "TextSpace"
		end
		
		Metrics::Timer.new "set up environment" do
			@camera = TextSpace::Camera.new
			
			@font = TextSpace::Font.new "Lucida Sans Unicode"
		end
		
		Metrics::Timer.new "open file" do
			@filepath = File.expand_path save_path
			
			# the opening of a space will implicitly cache all fonts used in the file
			@space = TextSpace::Space.load @filepath
		end
		
		Metrics::Timer.new "setup actions and inputs" do
			# TOOD: consider moving actions under an "Actions" module?
			@actions = TextSpace::ActionGroup.new
			@actions.add(
				TextSpace::MoveCaretAndSelectObject.new(@space),
				TextSpace::Move.new(@space),
				TextSpace::PanCamera.new,
				TextSpace::SpawnNewText.new(@space, @font),
				TextSpace::Resize.new(@space)
			)
			
			@input = TextSpace::InputSystem.new(@space, @actions)
		end
		
		Metrics::Timer.new "load interface" do
			@ui = TextSpace::Space.load File.join(Dir.pwd, "data", "UI.yml")
		end
		
		
		
		# @line = TextSpace::Line.new CP::Vec2.new(0,0), CP::Vec2.new(0,200), 5
		
		
		# @space.add TextSpace::Circle.new 20
	end
	
	def update
		@space.update
		
		@actions.update
		@input.update
	end
	
	def draw
		# Render screen space
		# (UI etc)
		@ui.draw
		
		
		self.flush
		
		
		# Render world space
		@camera.draw do
			@space.draw
			
			# @line.draw
		end
	end
	
	def shutdown
		@input.shutdown
		
		# @space.gc # TODO: make gc step unnecessary by removing elements from space as they expire
		@space.dump @filepath
	end
	
	
	def button_down(id)
		@input.button_down id
	end
	
	def button_up(id)
		@input.button_up id
	end
	
	def needs_cursor?
		@input.needs_cursor?
	end
end


filepath = ARGV[0]
# filename ||= "default.yml"
raise "No file path specified" unless filepath

x = Window.new filepath
x.show
x.shutdown