module ThoughtTrace
	module Constraints



class Visualization
	def initialize
		@timer = Timer.new
	end
	
	
	def update
		# update animation state, etc
		# do not make any changes to Entity data
		# 
		# this phase has now become completely independent of entity data
		# (maybe this should be removed?)
		
		@timer.update # check to see if the desired time has elapsed or not
		
		
		if @state == :active
			update_active(a,b)
		elsif @state == :inactive
			update_inactive(a,b)
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
		def initialize
			@start_time = nil
			@time = 0
		end
		
		def update
			if now - @start_time >= @time
				if @block
					@block.call 
					@block = nil
				end
			end
		end
		
		def wait(time, &block)
			@start_time = now()
			@time = time
			@block = block
		end
		
		private
		
		# returns an integer timestamp for the current time (ms resolution)
		def now
			Gosu::milliseconds
		end
		
		# compute the time elapsed between two millisecond timestamps
		# takes into account possibility of the timer wrapping back around
		def elapsed_time(start, stop)
			
		end
	end
	
	
	
	
	
	
	# TODO: consider having two separate objects for active and inactive states, so that the two states can keep their data completely separate
	# TODO: consider that only one visualization object needs to be made - this wrapper - and that the inside classes could be something else? or maybe that those objects should be the visualization classes, and this wrapper should be called something else
	def update_active(a,b)
		
	end
	
	def update_inactive(a,b)
		
	end
	
	def draw_active(a,b)
		
	end
	
	def draw_inactive(a,b)
		
	end
end


end
end