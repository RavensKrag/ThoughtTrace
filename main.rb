#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'gosu'

require './Font'

class Window < Gosu::Window
	def initialize
		width = 500
		height = 500
		fullscreen = false
		
		update_interval = 1/60.0
		
		super(width, height, fullscreen, update_interval)
		
		
		@f = TextSpace::Font.new self, "Lucida Sans Unicode"
	end
	
	def update
		
	end
	
	def draw
		@f.draw "hello world", 0,0,0
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
			
			
			when Gosu::MsWheelUp
				@f.height += 1
			when Gosu::MsWheelDown
				@f.height -= 1
		end
	end
	
	def button_up(id)
		
	end
	
	def needs_cursor?
		true
	end
end

Window.new.show