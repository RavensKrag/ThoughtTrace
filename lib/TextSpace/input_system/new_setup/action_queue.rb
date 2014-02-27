# Manages active actions
# (maybe these should be HumanActions, rather than Actions?)

class ActionQueue
	def initialize
		@active = nil
	end
	
	# change the currently managed action out, and put a new one in it's place
	def switch(action, point)
		# setup new one
		action.setup self, point
		
		# clean up old one, and be rid of it
		@active.cleanup
		@active = nil
		
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