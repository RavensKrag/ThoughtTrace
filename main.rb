#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'bundler/setup'

require 'gosu'
require 'gl'

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