module DIS
	def self.timestamp
		Gosu::milliseconds
	end
end


class Window < Gosu::Window
	attr_reader :camera
	
	def initialize(filepath)
		@filepath = filepath
		
		Metrics::Timer.new "setup window" do
			# Necessary to allow access to text input buffers, etc
			# Also allows for easy transformation of vectors through camera
				# (see monkey_patches/Chipmunk/Vec2)
			# Also used for global access of mouse (should probably reconsider this)
			# Allows for loading serialized fonts (can't really pass window there?)
			
			
			# store window in global variable
				# but do not make any new properties visible
				# (necessary both for text input as well as the initialization of things like Font objects)
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
			@document = ThoughtTrace::Document.load @filepath
			@document.bind_to_window self
			
			
			# This needs to be set because vectors do coordinate space conversions by getting the camera though the global window variable. Need to figure out a way to do that better.
			@camera = @document.camera
		end
		
		
		Metrics::Timer.new "setup input system" do
			@input = ThoughtTrace::InputManager.new self, @document
		end
	end
	
	def update
		@document.update
		@input.update
	end
	
	def draw
		@document.draw do
			# input system is drawing things in world-space, not screen space
			# need to fix that, or the caret will often not appear on screen
			@input.draw
		end
		
	end
	
	def on_shutdown
		@input.shutdown
		
		@document.gc
		@document.dump @filepath
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
end
