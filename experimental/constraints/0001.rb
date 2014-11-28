
trigger     # condition for application
apply_tick  # apply one iteration of the constraint
visualize   # let the user see the data

# monad, or monad-like structure that controls how many things are affected
foo =
	many 
	single
	one_way
	two_way
	n_way





x = foo(trigger, apply_tick, visualize)


x.update
x.draw



# potentially should avoid looping flow
# only want data to flow in one iteration per "game tick"
# don't want any real loops
# circular flow should be applied in a spiral that gets applied one iteration per "game tick"
# rather than all at once like a while loop
# (consider how infrequently you want to use while loops for circular flow in games)
# (consider also the Massive Chalice exploding armor: triggers in a chain, but will not cause loops)

class Foo
	def initialize(trigger, apply_tick, visualize)
		# where is the monad?
		@trigger = trigger
		@apply_tick = apply_tick
		@visualize = visualize
		
		
		@dirty = false # has one tick been applied this frame?
	end
	
	
	
	
	# only allow running this once per game tick
	def update
		unless @dirty
		if @trigger.call
		
			@apply_tick.call
		
		@dirty = true
		end
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
	
	
	# reset the foo for the next game tick
	# aka
	# reset between game ticks
	def clear
		@dirty = false
	end
end




class Collection
	def initialize
		@list = []
	end
	
	
	def update
		@list.each do |constraint|
			constraint.update
		end
		
		# clean up the flags when you're done
		@list.each &:clear
	end
	
	
	def draw
		@list.each &:draw
	end
end



