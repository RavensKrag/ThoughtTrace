#!/usr/bin/env ruby
# Dir.chdir File.dirname(__FILE__)

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
# puts __FILE__
path_to_root = File.expand_path '../..', __FILE__
full_path = File.join path_to_root, "lib", "PACKAGE_NAME"


Dir.chdir full_path do
	[
		'./monkey_patches',
		
		'./THINGS_TO_DO_THEM_ON/cameras/camera',
		'./THINGS_TO_DO_THEM_ON/collections/groups/selection',
		
		'./THINGS_TO_DO/actions',
		'./THINGS_TO_DO/input_system',
		
		# './drawing',
		
		'./utilities/multires_caching/font', # required by entities/text
		
		'./space',
		'./drawing',
		'./THINGS_TO_DO_THEM_ON/entities'
	
	
	
	
	].each do |path|
		absolute_path = File.expand_path(path, Dir.pwd)
		
		# puts absolute_path
		
		# if it's a path, require_all
		# if it's a file, require
		# ---------------------------
		if File.directory? absolute_path
			puts "LOAD DIR: #{absolute_path}"
			require_all absolute_path
		# elsif File.file? absolute_path
		else
			puts "LOAD FILE: #{absolute_path}"
			require absolute_path
		end
	end
end


# # Make sure that the main program executes in the ROOT/bin directly,
# # although files are loaded from under ROOT/lib
# Dir.chdir File.dirname(__FILE__)
# puts "Working directory: #{Dir.pwd}"


# better to not change working directory so that
# command line parameters function as expected.




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
		
		
		# Setup rest of environment
		@filepath = save_path
		@space = TextSpace::Space.load @filepath
		
		
		@camera = TextSpace::Camera.new
		
		
		
		@font = TextSpace::Font.new "Lucida Sans Unicode"
		
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
		
		
		@ui = TextSpace::Space.load File.join(Dir.pwd, "data", "UI.yml")
		
		
		
		
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