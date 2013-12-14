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
	
	def initialize
		# Necessary to allow access to text input buffers, etc
		# Also allows for easy transformation of vectors through camera
			# (see monkey_patches/Chipmunk/Vec2)
		# Also used for global access of mouse (should probably reconsider this)
		$window = self
		
		# Setup window
		height = 900
		width = (height.to_f*16/9).to_i
		fullscreen = false
		
		update_interval = 1/60.0 * 1000
		
		super(width, height, fullscreen, update_interval)
		self.caption = "TextSpace"
		
		
		# Setup rest of environment
		@camera = TextSpace::Camera.new
		
		@space = TextSpace::Space.new
		
		
		# TOOD: consider moving actions under an "Actions" module?
		@actions = TextSpace::ActionGroup.new
		@actions.add(
			# TextSpace::MoveCaretAndSelectObject.new(@space),
			TextSpace::Move.new(@space),
			TextSpace::PanCamera.new,
			# TextSpace::SpawnNewText.new(@space)
		)
		
		@input = TextSpace::InputSystem.new(@space, @actions)
		
		
		# Populate environment
		@font = TextSpace::Font.new "Lucida Sans Unicode"
		
		text = TextSpace::Text.new @font
		text.string = "Hello World"
		
		@space.add text
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