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
		
		@bindings = {
			:move => [Gosu::MsLeft],
			:scale => [Gosu::MsRight],
			
			:increase_size => [Gosu::MsWheelUp, Gosu::KbUp],
			:decrease_size => [Gosu::MsWheelDown, Gosu::KbDown]
		}
		
		@mouse = TextSpace::MouseHandler.new Gosu::MsLeft
		
		
		# Load all the data
		# foreach does not traverse in alphabetical order,
		# so load all the things up, sort them by filename, and discard the filename info
		@objects = Array.new
		data_dir = File.join(File.dirname(__FILE__), "data")
		Dir.foreach data_dir do |item|
			next if item == '.' or item == '..'
			# next unless File.exist?
			
			filepath = File.join(data_dir, item)
			@objects.push [filepath, TextSpace::Text.load(@font, filepath)]
		end
		@objects = @objects.sort_by {|x| x[0]}.collect{|x| x[1]}
		@objects.each {|i| puts i}
	end
	
	def update
		@objects.each do |obj|
			obj.update
		end
		@mouse.update
		
		if @mouse.selected && @scaling
			@mouse.selected.height = mouse_y - @mouse.selected.position.y
		end
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
				shutdown
		end
		
		if @bindings[:increase_size].include? id
			@mouse.selected.height += 1
		elsif @bindings[:decrease_size].include? id
			@mouse.selected.height -= 1
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
	
	def shutdown
		# FIXME: Files not saving with the same filenames every time
		@objects.each_with_index do |obj, i|
			filepath = File.join(File.dirname(__FILE__), "data", "#{"%05d" % i}.yml")
			obj.dump(filepath)
		end
		
		close
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