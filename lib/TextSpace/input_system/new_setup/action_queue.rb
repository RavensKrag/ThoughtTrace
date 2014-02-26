# Manages active actions
# (maybe these should be HumanActions, rather than Actions?)

# Expanding this to an actual queue may be desirable,
# because it would allow for really easy automation.
# You could just load up some actions into a list, and be done with it.
# But maybe that should be a separate class?
class ActionQueue
	def initialize
		@active = nil
		@next = nil
	end
	
	# put a new state on the stack
	def queue(action)
		"Can not queue more than one action." unless @action.nil?
		# A queue that can only queue one thing isn't really much of queue... but w/e.
		# The stack doesn't have this problem, and can add as many layers as it wants,
		# but it has a bunch of garbage that lingers around
		
		
		@next = action
		@next.setup(self, point)
		
		
		dequeue
	end
	
	# update only the top element of the stack
	def update
		@active = @next if @active.nil? # move up the next action if able
		
		@active.update
	end
	
	# remove top element of stack, and clean up that action state
	# (used more as an interrupt or a cleanup phase than anything else)
	# not sure if this method needs to be exposed or not.
	def dequeue
		@active.cleaup
		@active = nil
	end
end