# Manages active actions
# (maybe these should be HumanActions, rather than Actions?)

# this is a rather weird system, because you just put things into it,
# and it spits them out automatically.
# As such #push does not work exactly how #push works with a stack
class ActionStash
	def initialize
		@active = nil
	end
	
	# change the currently managed action out, and put a new one in it's place
	# (there might not be a currently set action, 'switch' is a rather odd name)
	
	# put a new thing into the collection space
	# this action will displace any action which currently inhabits the space
	def push(action, point)
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
		@active.update point
	end
	
	# Get rid of the currently tracked action. (Make sure to clean up)
	def clear
		@active.cleanup
		@active = nil
	end
end