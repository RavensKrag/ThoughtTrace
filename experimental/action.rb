# Things that can be performed on existing Entities
# 
# stored within Entity objects, accessed similar to methods
# mutates data from components
# can trigger other Actions (can only pick from Actions specified on the list)
module TextSpace
	module InputSystem

class Action
	interface :foo_act
	
	components :foo, :baz			# these are the data blocks that are manipulated by this Action
	actions :bleh, :things, :buttz	# must specify actions in this list if you want to trigger them
	
	
	attr_accessor :components, :actions
	
	
	
	# The Entity will be the one to actually set this variable.
	# It will be done as the Entity is added into a space.
	# (and cleared when Entity leaves a Space)
	attr_accessor :space # Space the parent Entity is inside of. Used for creating new Entities.
	
	# trying to keep init and setup separated so that the binding between entity and action
	# can be made explicit at the point where the action is declared.
	# Otherwise, you make it seem like the binding is tight, by declaring the two thing together,
	# but the linkage can actually be set to something completely different.
	# That would be weird and dumb.
	def initialize(entity)
		@entity = entity
	end
	
	
	# Executed before adding to queue
	def setup(stash, point)
		@stash = stash
	end
	
	def update(point)
		
		
		
		# under certain conditions
		shard = Entity.new			# or some type of Entity
		
		# need to add this shard to the space, or it will just disappear
		# this design implies that all Entities live within the space
		# which is kinda what I want, but it also means that the Physics module is "special"
		# because essentially, all Entities have to have physics,
		# but it's not just bolted on like in Unity.
		# (not sure if that's better or worse)
		@space.add shard
		
		return @stash.pass_control shard.move		# or some other action
	end
	
	# Executed after removed from queue
	def cleanup
		
	end
end



end
end