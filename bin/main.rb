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
full_path = File.join path_to_root, "lib", "TextSpace"

Dir.chdir full_path do
	require './utilities/performance_timer'
	
	Metrics::Timer.new "load scripts" do
	
		[
			'./utilities/meta',
			
			# require_all seems to snip the Class#inherited callback.
			# wait, but only for recursive add or something?
			# one directory at a time seems to be fine...
			# './entities'
			'./entities/share/',
			'./entities/actions/',
			'./entities/components/',
			'./entities/'
			
		
		
		
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
			self.caption = "TextSpace"
		end
		
		
		
		# components = {:physics => "dummy"}
		# actions = {:move => "blob"}
		
		# a = Action.new components, actions
		# # puts a.dependencies
		# puts Action.dependencies
		
		
		# # puts Action.dependencies
		
		
		# move = Move.new components
		# puts Move.dependencies
		
		
		
		
		
		
		e = Entity.new
		e.add_component Physics
		e.add_action Move
	end
	
	def update
		# @input.update
	end
	
	def draw
		
	end
	
	def on_shutdown
		# @input.shutdown
		
		
	end
	
	
	def button_down(id)
		# @input.button_down id
		
		close if id == Gosu::KbEscape
	end
	
	def button_up(id)
		# @input.button_up id
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
