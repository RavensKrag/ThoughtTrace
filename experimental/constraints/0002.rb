# another sketch, this time "dirty" state is managed by the collection, not each object


class Foo
	def initialize(trigger, apply_tick, visualize)
		# where is the monad?
		@trigger = trigger
		@apply_tick = apply_tick
		@visualize = visualize
	end
	
	
	
	
	# only allow running this once per game tick
	def update
		if @trigger.call		
			@apply_tick.call
		end
	end
	
	
	# always render constraint, even if it has not been updated
	# (but maybe it should have a different appearance when it has been updated recently?)
		# can add that later. would actually be complicated
		# would have to track ticks,
		# like the way the text input caret works
		# in order to make sure that it doesn't just render the info for one frame and then go away
		# because no one would be able to see that
	def draw
		@visualize.call
	end
end




class Collection
	def initialize
		@list = []
		@set = Set.new
	end
	
	
	def update
		@list.each do |constraint|
			constraint.update
			@set.add constraint # flag constraints as run, so you don't trigger them twice
		end
		
		# clean up the flags when you're done
		@set.clear
	end
	
	
	def draw
		@list.each &:draw
	end
end


