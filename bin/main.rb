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
full_path = File.join path_to_root, "lib", "ThoughtTrace"

Dir.chdir full_path do
	require './utilities/performance_timer'
	
	Metrics::Timer.new "load scripts" do
	
		[
			'./monkey_patches',
			
			'./utilities/meta',
			'./utilities/font',
			
			'./space',
			
			# require_all seems to snip the Class#inherited callback.
			# wait, but only for recursive add or something?
			# one directory at a time seems to be fine...
			# './entities'
			'./entities/share/',
			'./entities/actions/',
			'./entities/components/',
			'./entities/',
			
			'./cameras/camera',
			
			
			# './input_system'
				'./input_system/human_action',
				
				'./input_system/action_stash',
				'./input_system/action_selector',
				
				'./input_system/input_abstraction',
				# './input_system/human_actions' # currently empty folder
				
				'./input_system/input_manager',
			
			
			# serialization
			'./serialization/compiled_files'
		
		
		
		].each do |path|
			begin
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
			rescue LoadError => e
				puts "LOAD ERROR: Failed to load #{path}"
				
				raise e
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
	
	def initialize
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
			self.caption = "ThoughtTrace"
		end
		
		
		
		Metrics::Timer.new "setup physics space" do
			@filepath = './data/test'
			@space = ThoughtTrace::Space.load @filepath
		end
		
		
		Metrics::Timer.new "create camera" do
			@camera = ThoughtTrace::Camera.new
		end
		
		
		Metrics::Timer.new "setup input system" do
			@input = ThoughtTrace::InputSystem::InputManager.new @space, @camera
		end
		
		
		
		
		@space.add ThoughtTrace::Rectangle.new 200, 200
	end
	
	def update
		@space.update
		@input.update
	end
	
	def draw
		@camera.draw do
			@space.draw
		end
	end
	
	def on_shutdown
		@input.shutdown
		
		@space.dump File.join(@filepath, 'text.csv')
	end
	
	
	def button_down(id)
		@input.button_down id
		
		close if id == Gosu::KbEscape
	end
	
	def button_up(id)
		@input.button_up id
	end
	
	def needs_cursor?
		# @input.needs_cursor?
		true
	end
end


# filepath = ARGV[0]
# filename ||= "default.yml"
# raise "No file path specified" unless filepath

# x = Window.new filepath
x = Window.new
x.show
x.on_shutdown
