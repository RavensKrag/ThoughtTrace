module ThoughtTrace
	module Constraints



class Visualization
	def initialize
		@timer = Timer.new
		@state = :inactive
	end
	
	
	def update
		# update animation state, etc
		# do not make any changes to Entity data
		# 
		# this phase has now become completely independent of entity data
		# (maybe this should be removed?)
		
		@timer.update # check to see if the desired time has elapsed or not
		
		
		if @state == :active
			update_active
		elsif @state == :inactive
			update_inactive
		else
			raise 'wat'
		end
	end
	
	def draw(a,b)
		# apply visualization data to the Entity objects as necessary
		# visualize the given pair of entities
		
		
		# draw different things depending on state
		if @state == :active
			draw_active(a,b)
		elsif @state == :inactive
			draw_inactive(a,b)
		else
			raise 'wat'
		end
	end
	
	def activate
		@state = :active
		
				# time to wait, in ms
		@timer.wait(3000) do
			@state = :inactive
		end
		
		
		# ALTERNATE:
		# start up
		# wait for some condition
		# return to inactive state
		# (can specify whatever condition you want)
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
	
	
	
	
	
	
	# TODO: consider having two separate objects for active and inactive states, so that the two states can keep their data completely separate
	# TODO: consider that only one visualization object needs to be made - this wrapper - and that the inside classes could be something else? or maybe that those objects should be the visualization classes, and this wrapper should be called something else
	def update_active
		
	end
	
	def update_inactive
		
	end
	
	def draw_active(a,b)
		
	end
	
	def draw_inactive(a,b)
		
	end
end


end
end