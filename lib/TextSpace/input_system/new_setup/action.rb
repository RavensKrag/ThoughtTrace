# Things that can be performed on existing Entities
# 
# stored within Entity objects, accessed similar to methods
# mutates data from components
# can trigger other Actions (can only pick from Actions specified on the list)
class Action
	interface :foo_act
	
	components :foo, :baz			# these are the data blocks that are manipulated by this Action
	actions :bleh, :things, :buttz	# must specify actions in this list if you want to trigger them
	
	# trying to keep init and setup separated so that the binding between entity and action
	# can be made explicit at the point where the action is declared.
	# Otherwise, you make it seem like the binding is tight, by declaring the two thing together,
	# but the linkage can actually be set to something completely different.
	# That would be weird and dumb.
	
	def initialize(entity)
		@entity = entity
	end
	
	
	# executed pre-push
	def setup(stack, point)
		@stack = stack
	end
	
	def update(point)
		
		
		
		# under certain conditions
		shard = Entity.new			# or some type of Entity
		@stack.push shard.move		# or some other action
		signal_done_with_this_state
		
		
		# what if you only have one thing in the stack?
			# then when you put something new in the stack,
			# the current action would automatically end,
			# as it is being pushed out of the stack
			# (it really is a queue after all)
	end
	
	# executed post-pop
	def cleanup
		
	end
end