#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'gosu'

require 'chipmunk'
require 'require_all'

require_all './Chipmunk'

require './Camera'

require './Selection'

require './Font'
require './Text'

require './Mouse'

require './Space'


require 'set'

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
		
		@selection = TextSpace::Selection.new
		
		
		@debug_font = Gosu::Font.new self, "Arial", 30
		@debug_color = 0xffff0000
		
		
		# Load all the data
		filepath = File.join(File.dirname(__FILE__), "data", "save_data.yml")
		
		@space = TextSpace::Space.load filepath
		
		
		@mouse = TextSpace::MouseHandler.new @space, @selection do
			# event :edit_text do
				
			# end

			# event :delete_text_object do
				
			# end

			# event :select_single do
			# 	bind_to Gosu::MsLeft
				
			# 	click do |space|
			# 		# get object under cursor
			# 		# add object to selection
					
			# 		# save object so it can be de-selected later
			# 	end
				
			# 	drag do |space|
					
			# 	end
				
			# 	release do |space|
			# 		# remove object from selection
			# 	end
			# end

			# event :select_multiple do
				
			# end
			
			event :select_text_object do
				bind_to Gosu::MsLeft
				
				click do |space|
					obj = space.object_at position_vector
					
					unless obj
						puts "new text"
						obj = TextSpace::Text.new
						obj.position = position_vector
						
						space << obj
					end
					
					
					clear_selection
					
					
					obj.click
					obj.activate
					
					select obj
				end
				
				drag do |space|
					
				end
				
				release do |space|
					# clear_selection
				end
			end

			# event :select_portion_of_text do
				
			# end

			event :resize do
				bind_to Gosu::MsRight
				
				click do |space|
					@resize_selection = space.object_at position_vector
					@first_position = @resize_selection.position
					@resize_basis = position_vector
					
					@screen_position = CP::Vec2.new($window.mouse_x, $window.mouse_y)
				end
				
				drag do |space|
					if @resize_selection
						# TODO: Only drag if delta exceeds threshold to prevent accidental drag from click events.  Delta in this case should be measured screen-relative
						screen_position = CP::Vec2.new($window.mouse_x, $window.mouse_y)
						screen_delta = screen_position - @screen_position
						
						if screen_delta.length > 2
							@resize_selection.height = position_vector.y - @resize_selection.position.y
						end
					end
				end
			end

			event :move_text do
				bind_to Gosu::MsLeft
				
				click do |space|
					# select text under cursor
					@drag_selection = space.object_at position_vector
					
					if @drag_selection
						# select @drag_selection
						# establish basis for drag
						@move_text_basis = position_vector
						# store original position of text
						@original_text_position = @drag_selection.position
					end
				end
				
				drag do |space|
					if @drag_selection
						# calculate movement delta
						delta = position_vector - @move_text_basis
						# displace text object by movement delta
						@drag_selection.position = @original_text_position + delta
					end
				end
				
				release do |space|
					
				end
			end
			
			event :pan_camera do
				bind_to Gosu::MsMiddle
				
				click do |space|
					# Establish basis for drag
					@pan_basis = position_vector
				end
				
				drag do |space|
					# Move view based on mouse delta between the previous frame and this one.
					mouse_delta = position_vector - @pan_basis
					
					$window.camera.position -= mouse_delta
					
					@pan_basis = position_vector
				end
				
				release do |space|
					
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