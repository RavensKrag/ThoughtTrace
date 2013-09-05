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
			
			event :spawn_new_text do
				bind_to Gosu::MsLeft
				
				pick_object_from :point do |vector|
					puts "new text"
					obj = TextSpace::Text.new
					obj.position = position_in_world
					
					obj
				end
				
				click do |space, obj|
					clear_selection
					
					obj.click
					obj.activate
					
					select obj
				end
			end
			
			event :select_text_object do
				bind_to Gosu::MsLeft
				
				pick_object_from :space
				
				click do |space, obj|
					clear_selection
					
					obj.click
					obj.activate
					
					select obj
				end
				
				drag do |space, selection|
					
				end
				
				release do |space, selection|
					# clear_selection
				end
			end
			
			# event :select_portion_of_text do
				
			# end
			
			event :resize do
				bind_to Gosu::MsRight
				
				pick_object_from :space
				
				click do |space, selection|
					@first_position = selection.position
					@resize_basis = position_in_world
					
					@screen_position = position_on_screen
				end
				
				drag do |space, selection|
					# TODO: Only drag if delta exceeds threshold to prevent accidental drag from click events.  Delta in this case should be measured screen-relative
					screen_delta = position_on_screen - @screen_position
					
					if screen_delta.length > 2
						selection.height = position_in_world.y - selection.position.y
					end
				end
			end
			
			event :move_text do
				bind_to Gosu::MsLeft
				
				pick_object_from :space 
				# pick_object_from :space do |object|
				# 	object
				# end
				
				click do |space, selection|
					# select @drag_selection
					# establish basis for drag
					@move_text_basis = position_in_world
					# store original position of text
					@original_text_position = selection.position
				end
				
				drag do |space, selection|
					# calculate movement delta
					delta = position_in_world - @move_text_basis
					# displace text object by movement delta
					selection.position = @original_text_position + delta
				end
				
				release do |space, selection|
					
				end
			end
			
			event :pan_camera do
				bind_to Gosu::MsMiddle
				
				click do |space|
					# Establish basis for drag
					@pan_basis = position_in_world
				end
				
				drag do |space|
					# Move view based on mouse delta between the previous frame and this one.
					mouse_delta = position_in_world - @pan_basis
					
					$window.camera.position -= mouse_delta
					
					@pan_basis = position_in_world
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