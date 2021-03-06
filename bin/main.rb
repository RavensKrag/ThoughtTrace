module DIS
	def self.timestamp
		Gosu::milliseconds
	end
end


class Window < Gosu::Window
	attr_reader :camera
	
	def initialize(filepath)
		raise "no filepath given" if filepath.nil? or filepath == ''
		
		Metrics::Timer.new "setup window" do
			# Necessary to allow access to text input buffers, etc
			# Also used for global access of mouse (should probably reconsider this)
				# * I think this is no longer true...?
			# Allows for loading serialized fonts (can't really pass window there?)
			
			
			# store window in global variable
				# but do not make any new properties visible
				# (necessary both for text input as well as the initialization of things like Font objects)
				# basically, the only things that use this global variable are
				# + font things
				# + things which draw custom OpenGL
				# 
				# opengl code can be rectified by passing the window to each #draw() command
				# but the font system probably needs to go through it's overhaul before it can get rid of the window global
			$window = self
			
			# Setup window
			height = 900
			width = (height.to_f*16/9).to_i
			fullscreen = false
			
			update_interval = 1/60.0 * 1000
			
			super(width, height, fullscreen, update_interval)
			self.caption = "ThoughtTrace"
		end
		
		
		
		
		
		Metrics::Timer.new "load document" do
			# setup physics space
			# setup factory to create new objects based on established prototypes
			# create camera
			@document = ThoughtTrace::Document.new
			@document.load filepath
			@document.bind_to_window self
			
			
			# This needs to be set because vectors do coordinate space conversions by getting the camera though the global window variable. Need to figure out a way to do that better.
			@camera = @document.camera
		end
		
		
		Metrics::Timer.new "setup input system" do
			@input = ThoughtTrace::InputManager.new self, @document
		end
	end
	
	def update
		@input.update
		@document.update
	end
	
	def draw
		@document.draw do
			# input system is drawing things in world-space, not screen space
			# need to fix that, or the caret will often not appear on screen
			@input.draw
		end
		
		
		# debug_show_mouse_position
	end
	
	def on_shutdown
		@input.on_shutdown
		
		@document.gc
		@document.dump # save to the same place you loaded from
	end
	
	
	def button_down(id)
		@input.button_down id
		
		close if id == Gosu::KbEscape
	end
	
	def button_up(id)
		@input.button_up id
	end
	
	def needs_cursor?
		# @input.needs_cursor?
		true
	end
	
	
	private
	
	def debug_show_mouse_position
		# debug code: show current position of the mouse
		p = CP::Vec2.new(self.mouse_x, self.mouse_y)
		
		z = 10000
		color = Gosu::Color.argb(0x88ffff00)
		offset = 10
		self.draw_quad(
			p.x-offset, p.y-offset, color,
			p.x+offset, p.y-offset, color,
			p.x+offset, p.y+offset, color,
			p.x-offset, p.y+offset, color,
			z
		)
	end
end
