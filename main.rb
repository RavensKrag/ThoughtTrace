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
			# event :test_api do
			# 	bind_to Gosu::MsLeft
				
			# 	click do |space, selection|
			# 		puts "click"
			# 	end
				
			# 	drag do |space, selection|
			# 		puts "drag"
			# 	end
				
			# 	release do |space, selection|
			# 		puts "release"
			# 	end
			# end
			
			
			# event :edit_text do
				
			# end

			# event :delete_text_object do
				
			# end

			# event :select_single do
			# 	bind_to Gosu::MsLeft
				
			# 	click do |space, selection|
			# 		# get object under cursor
			# 		# add object to selection
					
			# 		# save object so it can be de-selected later
			# 	end
				
			# 	drag do |space, selection|
					
			# 	end
				
			# 	release do |space, selection|
			# 		# remove object from selection
			# 	end
			# end

			# event :select_multiple do
				
			# end
			
			# event :spawn_new_text do
			# 	bind_to Gosu::MsLeft
				
			# 	click do |space, selection|
			# 		# obj = $window.space.object_at position_vector
			# 		# obj ||= $window.spawn_new_text
					
			# 		# obj = TextSpace::Text.new
			# 		# obj.position = position_vector
					
			# 		puts "new text"
			# 		# obj.string = ["hey", "listen", "look out!", "watch out", "hey~", "hello~?"].sample
					
			# 		# space << obj
					
					
					
			# 		# @selected = obj
			# 		# selection.add @selected
			# 	end
				
			# 	drag do |space, selection|
					
			# 	end
				
			# 	release do |space, selection|
			# 		# selection.remove @selected
			# 	end
			# end

			# event :select_portion_of_text do
				
			# end

			# event :resize do
				
			# end

			# event :move_text do
			# 	bind_to Gosu::MsRight
				
			# 	click do |space, selection|
			# 		# select text under cursor
			# 		# establish basis for drag
			# 		# store original position of text
			# 	end
				
			# 	drag do |space, selection|
			# 		# calculate movement delta
			# 		# displace text object by movement delta
			# 	end
				
			# 	release do |space, selection|
					
			# 	end
			# end

			event :pan_camera do
				bind_to Gosu::MsMiddle
				
				click do |space, selection|
					# Establish basis for drag
					@drag_basis = position_vector
				end
				
				drag do |space, selection|
					# Move view based on mouse delta between the previous frame and this one.
					mouse_delta = position_vector - @drag_basis
					
					$window.camera.position -= mouse_delta
					
					@drag_basis = position_vector
				end
				
				release do |space, selection|
					
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