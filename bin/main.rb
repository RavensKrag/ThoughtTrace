module DIS
	def self.timestamp
		Gosu::milliseconds
	end
end


class Window < Gosu::Window
	attr_reader :camera
	
	def initialize
		Metrics::Timer.new "setup window" do
			# Necessary to allow access to text input buffers, etc
			# Also allows for easy transformation of vectors through camera
				# (see monkey_patches/Chipmunk/Vec2)
			# Also used for global access of mouse (should probably reconsider this)
			# Allows for loading serialized fonts (can't really pass window there?)
			$window = self
			
			# Setup window
			height = 900
			width = (height.to_f*16/9).to_i
			fullscreen = false
			
			update_interval = 1/60.0 * 1000
			
			super(width, height, fullscreen, update_interval)
			self.caption = "ThoughtTrace"
		end
		
		
		
		Metrics::Timer.new "setup physics space" do
			@filepath = './data/test'
			@space = ThoughtTrace::Space.load @filepath
		end
		
		
		Metrics::Timer.new "create camera" do
			@camera = ThoughtTrace::Camera.new
		end
		
		
		Metrics::Timer.new "setup input system" do
			@input = ThoughtTrace::InputManager.new self, @space, @camera
		end
	end
	
	def update
		@space.update
		@input.update
	end
	
	def draw
		@camera.draw do
			@input.draw
			@space.draw
		end
	end
	
	def on_shutdown
		@input.shutdown
		
		@space.dump @filepath
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
