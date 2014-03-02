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
		
		
		@stash = ActionStash.new # manages flow control for Actions
		
		
		
		# actions sorted in order of priority
		# each instance should have different action names
		@actions = [:move]
		
		@human_actions = [
			TextSpace::InputSystem::Spawn.new(@space, TextSpace::Text)
		]
	end
	
	def press
		# triggered on button press
							point = @mouse.position_in_world
							layers = CP::ALL_LAYERS
							group = CP::NO_GROUP
							set = nil
		entity = @space.point_query_best point, layers, group, set
		
		
		
		
		# lands on empty space, or an entity
		# if it lands on empty space
			# fire some spawning actions
		# if it lands on an entity, 
			# fire one of the actions managed by this selector
			# which can be processed by the selected entity
		
		
		if entity
			# manipulate existing entity
			
			
			# O(2n^2)  [create list #action_names = O(n); #include? O(n); #find O(n)]
			action_name = @actions.find { |action| entity.action_names.include? action } 
			
			
			raise "No action to perform" unless action_name
			
			
			@stash.pass_control entity.send(action_name), point
			
		else
			# spawn action
			# maybe chain into another action which manipulates the new Entity?
			
			
			# action = TextSpace::InputSystem::Spawn.new(@space, TextSpace::Text)
			# @stash.pass_control action, point
		end
		
		
		
	end
	
	def hold
		point = @mouse.position_in_world
		
		@stash.update(point)
	end
	
	def release
		@stash.clear
	end
end



end
end