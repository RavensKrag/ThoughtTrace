# Figure out what action to fire, and manage the state therein
# 
# Selects actions based on where entities were discovered,
# NOT based on what sort of entities are found.


# 2 major problem remain:
# + how to bind
	# how you do figure out what actions should be used under which scenarios?
		# some actions should only fire in empty space. some only affect certain kinds of entities.
		# (that's the old logic anyway)
	# how do you "bind" action names to their proper contexts?
	# what properties can be used to prevent collisions?
# + how to find the type of action to launch
	# where does the info come from?
	# how do you do this exactly?



# and then there's the other half of the problem:
# raw input -> abstracted complex inputs


# should mouse be contained it this class?
# at what point should the position of the mouse clicks be abstracted into just points?


# Storing the actual Actions in the Entities feels more like OOP,
# but it means Actions can be triggered outside of this structure (potentially)
# I like the freedom and potential for expansion, but it could possibly get ugly later on.
module TextSpace
	module InputSystem


class ActionSelector
	def initialize(space, selection, mouse)
		@space = space
		@selection = selection
		@mouse = mouse
		
		
		
		
		@action_names = [:foo, :bar, :baz]
		
		# if you're going to follow the legacy stile
		@action_names = {
			:selection => nil,
			:point => nil,
			:space => nil
		}
		# only can have one action name per slot
		# if you try to put an action where the name is already set, that is a collision
		# 
		# should put actions into the correct categories automatically
		# the user need only know what actions they want,
		# the designer of the action must know where the action should go
		
		
		
		@stash = ActionStash.new # manages flow control for Actions
	end
	
	def press
		# triggered on button press
							point = @mouse.position_in_world
							layers = CP::ALL_LAYERS
							group = CP::NO_GROUP
							set = nil
		entity = @space.point_query_best point, layers, group, set
		
		
		
		type = action_type(entity)
		action_name = @action_names[type]
		
		
		@stash.pass_control entity.send(action_name), point
	end
	
	def hold
		point = @mouse.position_in_world
		
		@stash.update(point)
	end
	
	def release
		@stash.clear
	end
	
	
	
	
	private
	
	
	def action_type(entity)
		# DISAMGUATE WHICH ACTION TO LAUNCH
		# (selection, point, space) are the legacy pick callback types
			# legacy callbacks returned either a valid object, or nil
			# getting a non-nil object was a signal that the pick was successful,
			# and that the action should proceed
			# 
			# the older algorithm is more concurrency-friendly,
			# but Ruby is really bad at that anyway
		case entity
			when nil
				# firing into empty space
				
				# CAN LAUNCH SPAWN ACTIONS
			when fizzbar
				# target selection shard
				# entity with an active selected sub-sector
			when fizzbar
				# target selection group
				# entity which is part of active selection group
			when fizzbar
				# target standard entity
		end
		
		
		
		
		
		
		
		
		
		if entity.nil?
			# firing into empty space
			
			# CAN LAUNCH SPAWN ACTIONS
			
		# elsif entity.
			# target selection shard
			# entity with an active selected sub-sector
			# [:split]
		elsif @selection.include? entity
			# target selection group
			# entity which is part of active selection group
		else
			# target standard entity
			# [:move]
		end
	end
	
	
	
	# get an appropriate entity, and access the proper action from it
	def query
		
	end
end



end
end