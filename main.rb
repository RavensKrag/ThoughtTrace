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
		
		@debug_font = Gosu::Font.new self, "Arial", 30
		@debug_color = 0xffff0000
		
		@f = TextSpace::Font.new self, "Lucida Sans Unicode"
	end
	
	def update
		
	end
	
	def draw
		@f.draw "Handglovery", 0,0,0
		
		
		
		debug_puts "#{@f.i} : #{@f.height} --- #{@f.debug_height}"
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
		end
		
		if id == Gosu::MsWheelUp || id == Gosu::KbUp
			@f.height += 1
		elsif id == Gosu::MsWheelDown || id == Gosu::KbDown
			@f.height -= 1
		end
	end
	
	def button_up(id)
		
	end
	
	def needs_cursor?
		true
	end
	
	private
	
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