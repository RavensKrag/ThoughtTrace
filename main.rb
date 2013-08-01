#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'gosu'

require 'chipmunk'

require './Font'

class Window < Gosu::Window
	def initialize
		height = 720
		width = (height.to_f*16/9).to_i
		fullscreen = false
		
		update_interval = 1/60.0
		
		super(width, height, fullscreen, update_interval)
		
		@debug_font = Gosu::Font.new self, "Arial", 30
		@debug_color = 0xffff0000
		
		@f = TextSpace::Font.new self, "Lucida Sans Unicode"
		@f_height = 10
		@fp = CP::Vec2.new(0,0)
		
		@bindings = {
			:move => Gosu::MsLeft,
			:scale => Gosu::MsRight
		}
		
		@mouse_down_location = CP::Vec2.new(0,0)
		@delta = CP::Vec2.new(0,0)
	end
	
	def update
		if @mouse_down
			@delta = mouse_delta
			# @fp.x = delta.x
			# @fp.y = delta.y
		end
		
		if @scaling
			@f_height = mouse_y - @fp.y
		end
	end
	
	def draw
		@f.draw "Handglovery", @f_height, @fp.x + @delta.x,@fp.y + @delta.y,0
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
		end
		
		if id == Gosu::MsWheelUp || id == Gosu::KbUp
			@f_height += 1
		elsif id == Gosu::MsWheelDown || id == Gosu::KbDown
			@f_height -= 1
		end
		
		
		if id == @bindings[:move]
			@mouse_down = true
			
			@mouse_down_location.x = mouse_x
			@mouse_down_location.y = mouse_y
		end
		
		if id == @bindings[:scale]
			@scaling = true
		end
	end
	
	def button_up(id)
		if id == @bindings[:move]
			@mouse_down = false
		end
		
		if id == @bindings[:scale]
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
	
	def mouse_delta
		CP::Vec2.new(mouse_x, mouse_y) - @mouse_down_location
	end
end

Window.new.show