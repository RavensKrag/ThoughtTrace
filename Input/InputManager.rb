require 'state_machine'

# need to run #update, #button_down, and #button_up for buttons, as well as more complex inputs
# need to make sure buttons are up to date before testing complex inputs
module InputManager
	class Input
		def initialize
			super()
			
			@callbacks = Hash.new
		end
		
		[:press, :hold, :release, :idle].each do |name|
			define_method name do |&block|
				@callbacks[name] = block
			end
		end
		
		state_machine :status, :default => :idle do
			state :idle do
				def update
					@callbacks[:idle].call
				end
			end
			
			state :hold do
				def update
					@callbacks[:hold].call
				end
			end
			
			
			event :press do
				transition :idle => :hold
			end
			
			event :release do
				transition :hold => :idle
			end
			
			
			after_transition :idle => :hold, :do => :press_callback
			after_transition :hold => :idle, :do => :release_callback
		end
		
		private
		
		def press_callback
			@callbacks[:press].call
		end
		
		def release_callback
			@callbacks[:release].call
		end
	end
	
	class Button < Input
		attr_accessor :binding
		
		def initialize(id, &block)
			super()
			
			@binding = id
			
			instance_eval &block
		end
		
		def ==(other)
			other = other.binding if other.is_a? self.class
			
			return @binding == other
		end
		
		def button_down(id)
			press if id == @binding
		end
		
		def button_up(id)
			release if id == @binding
		end
	end
	
	# Hit a bunch of buttons all at once
	# NOTE: Currently triggers when all are down, should probably only trigger when all down within a set delta time of each other
	class Chord < Input
		attr_reader :buttons
		
		def initialize(*buttons, &block)
			super()
			
			@buttons = buttons
			
			instance_eval &block
		end
		
		def ==(other)
			if other.is_a? self.class
				return @buttons == other.buttons
			elsif other.is_a? Array
				return @buttons == other
			else
				return false
			end
		end
		
		[:button_down, :button_up].each do |name|
			define_method name do |id|
				
				if @buttons.all?{ |b|  b.hold? }
					press
				else
					release
				end
				
			end
		end
	end
	
	# Hit a bunch of buttons in a certain order
	# Releases shortly after the last button is hit. Thus, can not be held.
	class Sequence < Input
		# Use enumeration-style rather than symbols so that input can be given as an array
		BUTTON = 0
		TIME_WINDOW = 1
		
		attr_reader :buttons
		
		def initialize(*buttons, &block)
			super()
			
			# example lists times in milliseconds
			# buttons = [
			# 	[Button.new(Gosu::KbF1), nil],
			# 	[Button.new(Gosu::KbF2), 20],
			# 	[Button.new(Gosu::KbF3), 20],
			# 	[Button.new(Gosu::KbF4), 20]
			# ]
			
			@timestamp = nil
			
			@i = 0
			@buttons = buttons
			
			instance_eval &block
		end
		
		def ==(other)
			if other.is_a? self.class
				return @buttons == other.buttons
			elsif other.is_a? Array
				return @buttons == other
			else
				return false
			end
		end
		
		def update
			super()
			
			reset if state_name == :hold # essentially, only call :hold callback for one frame
		end
		
		def button_down(id)
			button_data = @buttons[@i]
			
			if id == button_data[BUTTON] && button_data[BUTTON].hold?
				if within_time_window?
					if @i+1 < @buttons.size # any more buttons to process?
						# Advance if there's more
						@i += 1
					else
						# No more buttons
						fire
					end
				else
					timeout
				end
			end
		end
		
		def button_up(id)
			
		end
		
		def dt
			dt = timestamp - @timestamp
		end
		
		def within_time_window?
			if @i == 0
				# first button can fire whenever it wants to
				return true
			else
				return dt < @buttons[@i][TIME_WINDOW]
			end
		end
		
		def timestamp
			# defined as method so it can be easily overridden
			Gosu.milliseconds
		end
		
		# TODO: put counter reset elsewhere and turn this into callback name
		def timeout
			@i = 0
		end
		
		# TODO: put counter reset elsewhere and turn this into callback name
		# no need to reset callback, because there's already a :release
		# unless you intend to disambiguate between different types of releasing
		def reset
			@i = 0
			release
		end
		
		private
		
		def fire
			mark_timestamp
			
			press
			release
		end
		
		def mark_timestamp
			@timestamp = timestamp
		end
	end
	
	# Hit a bunch of buttons in a certain order
	# The timing between inputs is important.
	# While Sequence can be spammed, combos must be performed deliberately,
	# each button hit within a certain window, instead of before a certain timeout.
	class Combo < Sequence
		TIME_LENIENCE = 2
		# (all times should be in the same units)
		# (for demonstration, frames (assuming 60fps) are used (homage to fighting games))
		
		def initialize(*buttons, &block)
			super(*buttons, &block)
			
			# buttons = [
			# 	[button, time window, lenience]
			# 	[Button.new(Gosu::KbF1), nil, nil],
			# 	[Button.new(Gosu::KbF2), 5, 3],
			# 	[Button.new(Gosu::KbF3), 5, 3],
			# 	[Button.new(Gosu::KbF4), 3, 3]
			# ]
		end
		
		def ==(other)
			if other.is_a? self.class
				return @buttons == other.buttons
			elsif other.is_a? Array
				return @buttons == other
			else
				return false
			end
		end
		
		def within_time_window?
			# TODO: Refactor #within_time_window? in Sequence so only the ignore-first-button clause can be omitted here
			if @i == 0
				# first button can fire whenever it wants to
				return true
			else
				low = @buttons[@i][TIME_WINDOW]
				high = @buttons[@i][TIME_WINDOW] + @buttons[@i][TIME_LENIENCE]
				
				return dt.between? low, high
			end
		end
	end
end