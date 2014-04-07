# THIS CLASS IS CURRENTLY UNUSED
# would theoretically allow for returning to old actions
# (like the system stack)
# unlike the action stash, which is what is currently being used to handle actions
# the stack is currently in a conceptual / sketch stage, and doesn't currently work as intended



# Manages active actions
# (maybe these should be HumanActions, rather than Actions?)
# similar to how the "system stack" manages different function calls, this manages actions
class ActionStack
	def initialize
		@stack = Array.new
	end
	
	# put a new state on the stack
	def push(action, point)
		action.setup self, point
		
		@stack.push action
	end
	
	# update only the top element of the stack
	def update(point)
		@stack.last.update point
	end
	
	# remove top element of stack, and clean up that action state
	def pop
		@stack.pop.cleaup
	end
end


# how do you know you've returned to the action?
# and where do you return to?

# would need to specify an invariant in the action
	# the "update" action will only happen of the invariant is satisfied
	# would need to check the invariant every iteration
	
	# would not work exactly like the system stack
		# would not be able to return to the calling location
	# instead, you would return to the same action, but at the top of the "loop"
	# much like in a standard looping construct


# note that all cleanups would be performed in one sweep,
# this means that there's no need to worry about invariant
# you'll never return to the 'loop body'
	# kinda like a tail recursion optimization, because you can't return to the calling point