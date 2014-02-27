# Manages active actions
# (maybe these should be HumanActions, rather than Actions?)

# Expanding this to an actual queue may be desirable,
# because it would allow for really easy automation.
# You could just load up some actions into a list, and be done with it.
# But maybe that should be a separate class?
class ActionQueue
	def initialize
		@active = nil
	end
	
	# put a new state on the stack
	def queue(action, point)
		# --- put the new one in, and take the old one out
		# new in
		action.setup self, point
		
		# old out
		@active.cleanup
		@active = nil
		
		# --- move the new one from the staging area to the actual zone
		@active = action
	end
	
	# update only the top element of the stack
	def update(point)
		@active.update point
	end
	
	# remove top element of stack, and clean up that action state
	# (used more as an interrupt or a cleanup phase than anything else)
	# not sure if this method needs to be exposed or not.
	
	# can dequeue be called in such a way that remains an object in @next?
		# you would have to skip the update cycle
		# is there a way to queue and dequeue on the same tick with no update in between
		# if queue always proceeds dequeue,
	def dequeue
		@active.cleanup
		@active = nil
	end
end