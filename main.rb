#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'gosu'

require 'chipmunk'
require 'require_all'

require_all './Chipmunk'

require './Camera'

require './Font'
require './Text'

require './Mouse'

require './Space'

class Window < Gosu::Window
	attr_reader :camera, :mouse
	attr_reader :space
	
	def initialize
		$window = self
		
		height = 900
		width = (height.to_f*16/9).to_i
		fullscreen = false
		
		update_interval = 1/60.0
		
		super(width, height, fullscreen, update_interval)
		self.caption = "TextSpace"
		
		TextSpace::Text.default_font = TextSpace::Font.new "Lucida Sans Unicode"
		
		@camera = TextSpace::Camera.new
		
		@debug_font = Gosu::Font.new self, "Arial", 30
		@debug_color = 0xffff0000
		
		
		# Load all the data
		filepath = File.join(File.dirname(__FILE__), "data", "save_data.yml")
		
		@space = TextSpace::Space.load filepath
		
		
		@mouse = TextSpace::MouseHandler.new do
			on_mouse_over do |hovered|
				
			end
			
			on_mouse_out do |hovered|
				
			end
			
			button Gosu::MsLeft do
				on_click do |mouse_down_vector|
					puts "++++++++++click"
					
					@screen_position = CP::Vec2.new($window.mouse_x, $window.mouse_y)
					
					
					obj = $window.space.object_at position_vector
					obj ||= $window.spawn_new_text
					
					
					if @selection
						@selection.release
						@selection.deactivate
						
						
						@selection = nil
					end
					@selection = obj
					
					
					# fire other event things as necessary
					@selection.click
					
					@selection.activate
					
					@first_position = @selection.position
				end
				
				on_release do |mouse_down_vector|
					puts "---------release"
				end
				
				on_drag do |mouse_down_vector|
					if @selection
						# TODO: Only drag if delta exceeds threshold to prevent accidental drag from click events.  Delta in this case should be measured screen-relative
						screen_position = CP::Vec2.new($window.mouse_x, $window.mouse_y)
						screen_delta = screen_position - @screen_position
						
						if screen_delta.length > 2
							# puts "drag"
							
							# position_vector is the current mouse position
							# mouse_down_vector is where the mouse was on the initial button press
							mouse_delta = position_vector - mouse_down_vector
							
							@selection.position = @first_position + mouse_delta
						end
					end
				end
			end
			
			
			
			button Gosu::MsRight do
				on_click do |mouse_down_vector|
					puts ">>>>>>>>>Scale"
					
					
				end
				
				on_release do |mouse_down_vector|
					puts "<<<<<<<<-stop"
				end
				
				on_drag do |mouse_down_vector|
					if @selection
						@selection.height = position_vector.y - @selection.position.y
					end
				end
			end
			
			
			
			button Gosu::MsMiddle do
				on_click do |mouse_down_vector|
					# Establish basis for drag
					@drag_basis = position_vector
				end
				
				on_release do |mouse_down_vector|
					
				end
				
				on_drag do |mouse_down_vector|
					# Move view based on mouse delta between the previous frame and this one.
					mouse_delta = position_vector - @drag_basis
					
					$window.camera.position -= mouse_delta
					
					@drag_basis = position_vector
				end
			end
		end
		
		
		
		
		# set default font
		# 
		# camera
		# debug_out
			# debug_out#puts
		# space
		# mouse
		# selection
	end
	
	def update
		@space.update
		
		@mouse.update
	end
	
	def draw
		@camera.draw do
			@space.draw
		end
	end
	
	def spawn_new_text
		t = TextSpace::Text.new
		
		t.position = @mouse.position_vector
		
		puts "new text"
		# t.string = ["hey", "listen", "look out!", "watch out", "hey~", "hello~?"].sample
		
		@space << t
		
		return t
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
		end
		
		@mouse.button_down id
	end
	
	def button_up(id)
		@mouse.button_up id
	end
	
	def needs_cursor?
		true
	end
	
	def shutdown
		@mouse.shutdown
		@space.gc
		
		
		filepath = File.join(File.dirname(__FILE__), "data", "save_data.yml")
		@space.dump filepath
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

x = Window.new
x.show
x.shutdown