# THIS COLLECTION MANAGES ACTIONS
# this is being used and the direction the project is currently going in,
# rather than the Stack style



# Manages active actions
# (with work with both standard Actions and HumanActions)

# Never work with Actions directly.
# They should always be used in conjunction with a stash.
# It provides a way for actions to automatically chain into additional actions.


module ThoughtTrace


# Maybe the name should be changed? "Stash" isn't really that descriptive...

# The name ActionGlove isn't really that bad.
# it holds actions, and manages flow control.
# (not sure what gloves have to do with flow control though... "invisible hand"?)
class ActionStash
	def initialize
		@active = nil
	end
	
	# put a new thing into the collection space
	# this action will displace any action which currently inhabits the space
	# (consider returning the old action, so the action doesn't just disappear into the void)
	# (would really only be one pointer to the action, though, rather than the action itself)
	def pass_control(action, point)
		# setup new one
		action.setup self, point
		
		# if there's an action currently in play,
		# clean up old one, and be rid of it
		if @active
			@active.cleanup
			@active = nil
		end
		
		# store the new action
		@active = action
	end
	
	# update the tracked action
	def update(point)
		@active.update point if @active
	end
	
	# Get rid of the currently tracked action. (Make sure to clean up)
	def clear
		if @active
			@active.cleanup
			@active = nil
		end
	end
end



end