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
			TextSpace::MoveText.new(@space),
			TextSpace::PanCamera.new,
			# TextSpace::SpawnNewText.new(@space)
		)
		
		@input = TextSpace::InputSystem.new(@space, @actions)
		
		
		
		@paint_box = {
			:example => {
				:color1 => Gosu::Color.argb(0xffff0000),
				:color2 => Gosu::Color.argb(0xff00ff00),
				:color3 => Gosu::Color.argb(0xff0000ff)
			},
			
			:default_palette => {
				:default_font => Gosu::Color.argb(0xffFFFFFF),
				
				:text_background => Gosu::Color.argb(((0xff * 0.2).to_i << (8*3)) | 0x0000ff),
				
				:text_caret => Gosu::Color.argb(0xff8E68A4),
				
				:active => Gosu::Color.argb(((0xff * 0.15).to_i << (8*3)) | 0xff0000),
				:mouseover => Gosu::Color.argb(((0xff * 0.1).to_i << (8*3)) | 0x0000ff),
				
				:debug_font => Gosu::Color.argb(0xffFF0000),
				:highlight => Gosu::Color.argb(0x77FFFF00),
				:box_select => Gosu::Color.argb(0x33E1DBA9),
				
				:connection => Gosu::Color.argb(((0xff * 0.4).to_i << (8*3)) | 0x79E4D1),
				
				
				Gosu::KbF1 => Gosu::Color.argb(0xffFFFFFF),
				Gosu::KbF2 => Gosu::Color.argb(0xffE4DD79),
				Gosu::KbF3 => Gosu::Color.argb(0xff79E4D1),
				Gosu::KbF4 => Gosu::Color.argb(0xffD579E4),
				Gosu::KbF5 => Gosu::Color.argb(0xff7997E4),
				Gosu::KbF6 => Gosu::Color.argb(0xff446E51),
				Gosu::KbF7 => Gosu::Color.argb(0xff6E195B),
				Gosu::KbF8 => Gosu::Color.argb(0xff000000)
			}
		}
		
		# Populate environment
		@font = TextSpace::Font.new "Lucida Sans Unicode"
		
		text = TextSpace::Text.new @font, @paint_box[:default_palette]
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
	
	def button_down(id)
		@input.button_down id
	end
	
	def button_up(id)
		@input.button_up id
	end
	
	def needs_cursor?
		@input.needs_cursor?
	end
	
	def shutdown
		@input.shutdown
	end
end

x = Window.new
x.show
x.shutdown