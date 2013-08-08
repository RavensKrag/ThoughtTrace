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
		@objects = YAML.load_file(File.join(File.dirname(__FILE__), "data", "ALL_DUMP_TEST.yml"))
		p @objects
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
			@mouse.selected.height += 1 if @mouse.selected
		elsif @bindings[:decrease_size].include? id
			@mouse.selected.height -= 1 if @mouse.selected
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
		filepath = File.join(File.dirname(__FILE__), "data", "ALL_DUMP_TEST.yml")
		File.open(filepath, "w") do |f|
			f.puts YAML::dump(@objects)
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