#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'bundler/setup'

require 'gosu'

require 'DIS'

require 'chipmunk'
require 'require_all'

require_all './monkey_patches'

require './camera'
require './selection'

require_all './actions'
require_all './input_system'

require_all './drawing'

require './font' # required by entities/text
require './space'
require_all './entities'


module DIS
	def self.timestamp
		Gosu::milliseconds
	end
end

class Window < Gosu::Window
	attr_reader :camera
	attr_reader :space
	attr_reader :input
	
	def initialize
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
		@filepath = File.join(Dir.pwd, "data", "new_data.yml")
		
		@camera = TextSpace::Camera.new
		
		# @space = TextSpace::Space.new
		@space = TextSpace::Space.load @filepath
		
		
		@font = TextSpace::Font.new "Lucida Sans Unicode"
		
		# TOOD: consider moving actions under an "Actions" module?
		@actions = TextSpace::ActionGroup.new
		@actions.add(
			TextSpace::MoveCaretAndSelectObject.new(@space),
			TextSpace::Move.new(@space),
			TextSpace::PanCamera.new,
			TextSpace::SpawnNewText.new(@space, @font)
		)
		
		@input = TextSpace::InputSystem.new(@space, @actions)
	end
	
	def update
		@space.update
		
		@actions.update
		@input.update
	end
	
	def draw
		@camera.draw do
			@space.draw
		end
	end
	
	def shutdown
		@input.shutdown
		
		@space.gc # TODO: make gc step unnecessary by removing elements from space as they expire
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

x = Window.new
x.show
x.shutdown