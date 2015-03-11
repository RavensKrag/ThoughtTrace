require 'state_machine'

module ThoughtTrace
	module Constraints


class Visualization
	def initialize
		super()
		
		@timer = Timer.new
	end
	
	state_machine :state, :initial => :unbound do
		# no constraint targets
		state :unbound do
			def update
				
			end
			
			def draw(a,b)
				
			end
		end
		
		# have constraint targets
		state :bound do
			def update
				
			end
			
			def draw(a,b)
				
			end
		end
		
		# just applied constraint tick
		state :active do
			def update
				@timer.update
				
				
			end
			
			def draw(a,b)
				
			end
		end
		
		
		event :bind do
			transition :unbound => :bound
		end
		
		event :unbind do
			transition any => :unbound
		end
		
		event :activate do
			transition :bound => :active
		end
		
		event :rest do
			transition :active => :bound
		end
		
		
		before_transition  :bound => :active, :do => :activation_callback
	end
	
	
	def activation_callback
		puts "start"
		# time to wait, in ms
		@timer.wait(3000) do
			self.rest
		end
	end
	
	
	
	
	
	# needs separate states
	# * standard
	# * i-just-activated-and-passed-some data
	# (active and sleeping?)
	
	# want to write code like
	# do this
	# wait 3 sec
	# do some other stuff
	class Timer
		# NOTE: this will not work on JRuby. But I can't currently deploy for that anyway.
		# src: https://bugs.ruby-lang.org/issues/7517
		MAX_FIXNUM = 1 << (1.size * 8 - 2) - 1
		
		
		def initialize
			@start_time = nil
			@target_time = 0
		end
		
		def update
			if elapsed_time(@start_time, @target_time) >= @target_time
				if @block
					@block.call
					@block = nil
					@start_time = nil
				end
			end
		end
		
		def wait(time, &block)
			@start_time = now()
			@target_time = time
			@block = block
		end
		
		private
		
		# returns an integer timestamp for the current time (ms resolution)
		def now
			# NOTE: Gosu::milliseconds will always return a Fixnum
			Gosu::milliseconds
		end
		
		# compute the time elapsed between two millisecond timestamps
		# takes into account possibility of the timer wrapping back around
		def elapsed_time(start, stop)
			# NOTE: because of how this is implemented, the 'elapsed time' check in the code above will pass often if @target_time == 0. But the block will still only be called once, because after being called once, it will be freed.
			
			
			# need a way to separate 'never called' from 'timer overflow'
			# currently doing that by setting 'blank' state values to nil.
			# 
			# Would be nice to only init the timer if it was being used, but then you get a lot of "has the timer been initialized" logic floating around...
			return 0 if start == nil
			
			
			
			# ok, now that we know the timer was actually set up,
			# let's check to see what's up
			if start < stop
				# standard
				return stop - start
			else
				# wrap-around has occurred
					# measure from start to max, and from 0 to stop
					# (start..max) + (0..stop)
				return (MAX_FIXNUM - start) + (stop)
			end
		end
	end
end



end
end