#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'gosu'

require 'chipmunk'

require './Font'
require './Text'

require './Mouse'

class Window < Gosu::Window
	attr_reader :text
	
	def initialize
		height = 720
		width = (height.to_f*16/9).to_i
		fullscreen = false
		
		update_interval = 1/60.0
		
		super(width, height, fullscreen, update_interval)
		
		@debug_font = Gosu::Font.new self, "Arial", 30
		@debug_color = 0xffff0000
		
		@f = TextSpace::Font.new self, "Lucida Sans Unicode"
		
		@text = TextSpace::Text.new @f
		@text.height = 10
		
		@bindings = {
			:move => [Gosu::MsLeft],
			:scale => [Gosu::MsRight],
			
			:increase_size => [Gosu::MsWheelUp, Gosu::KbUp],
			:decrease_size => [Gosu::MsWheelDown, Gosu::KbDown]
		}
		
		@mouse = TextSpace::MouseHandler.new self, Gosu::MsLeft
	end
	
	def update
		@text.update
		@mouse.update
		
		if @scaling
			@text.height = mouse_y - @text.position.y
		end
	end
	
	def draw
		@text.draw "Handglovery", 0
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
		end
		
		if @bindings[:increase_size].include? id
			@text.height += 1
		elsif @bindings[:decrease_size].include? id
			@text.height -= 1
		end
		
		
		@mouse.button_down id
		
		if @bindings[:scale].include? id
			@scaling = true
		end
	end
	
	def button_up(id)
		@mouse.button_up id
		
		if @bindings[:scale].include? id
			@scaling = false
		end
	end
	
	def needs_cursor?
		true
	end
	
	
	
	
	def debug_puts(*args)
		output = ""
		args.each do |x|
			output += x.to_s
		end
		
		debug_z = 10000 # something really large
		@debug_font.draw output, 0,0,debug_z, 1,1, @debug_color
	end
end

Window.new.show