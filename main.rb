#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'gosu'

require 'chipmunk'

require './Camera'

require './Font'
require './Text'

require './Mouse'

class Window < Gosu::Window
	attr_reader :camera
	attr_reader :objects
	
	def initialize
		$window = self
		
		height = 720
		width = (height.to_f*16/9).to_i
		fullscreen = false
		
		update_interval = 1/60.0
		
		super(width, height, fullscreen, update_interval)
		self.caption = "TextSpace"
		
		@camera = TextSpace::Camera.new
		
		@debug_font = Gosu::Font.new self, "Arial", 30
		@debug_color = 0xffff0000
		
		@font = TextSpace::Font.new "Lucida Sans Unicode"
		
		
		
		
		@mouse = TextSpace::MouseHandler.new do
			on_mouse_over do |hovered|
				
			end
			
			on_mouse_out do |hovered|
				
			end
			
			button Gosu::MsLeft do
				on_click do |mouse_down_vector|
					puts "++++++++++click"
					
					obj = object_at_point position_vector
					obj ||= $window.spawn_new_text
					
					
					if @selection
						@selection.release
						
						@selection = nil
					end
					@selection = obj
					
					
					# fire other event things as necessary
					@selection.click
					@first_position = @selection.position
				end
				
				on_release do |mouse_down_vector|
					puts "---------release"
				end
				
				on_drag do |mouse_down_vector|
					if @selection
						puts "drag"
						
						# position_vector is the current mouse position
						# mouse_down_vector is where the mouse was on the initial button press
						mouse_delta = position_vector - mouse_down_vector
						
						@selection.position = @first_position + mouse_delta
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
		
		
		# Load all the data
		@objects = YAML.load_file(File.join(File.dirname(__FILE__), "data", "ALL_DUMP_TEST.yml"))
		p @objects
	end
	
	def update
		@objects.each do |obj|
			obj.update
		end
		
		@mouse.update
	end
	
	def draw
		@camera.draw do
			@objects.each do |obj|
				obj.draw
			end
		end
	end
	
	def spawn_new_text
		t = TextSpace::Text.new(@font)
		
		t.position = CP::Vec2.new(mouse_x, mouse_y)
		
		t.string = ["hey", "listen", "look out!", "watch out", "hey~", "hello~?"].sample
		
		@objects << t
		
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
		filepath = File.join(File.dirname(__FILE__), "data", "ALL_DUMP_TEST.yml")
		File.open(filepath, "w") do |f|
			f.puts YAML::dump(@objects)
		end
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