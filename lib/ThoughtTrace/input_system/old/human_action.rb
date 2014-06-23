# Allow scripting of things that are logically 'one action' from a human perspective
# and thus need to be grouped to work with the human interface system.
# These things would not normally elsewise be encapsulated.
	# ex) spawning a new entity of a certain type and placing it within the world

# for Actions:
	# query for object
	# 


# Should HumanActions operate on classes of Entitys,
# like how Actions operate on types of Entities (instances)?
	# could even restrict to certain component / action sets,
	# because the dependency lists are stored at the class level
module ThoughtTrace
	module InputSystem


class HumanAction
	def initialize
		
	end
	
	
	# should have the same interface as a standard Action
	
	def setup(stash, point)
		@stash = stash
		
		
	end
	
	def update(point)
		# chain into move?
		# maybe it's different depending on the entity spawned?
		# like, selection boxes or text boxes should chain into resize
	end
	
	def cleanup
		
	end
end


end
end








module ThoughtTrace
	module InputSystem


class Spawn < HumanAction
	def initialize(space, entity_class)
		@space = space
		@klass = entity_class
	end
	
	
	# should have the same interface as a standard Action
	
	def setup(stash, point)
		@stash = stash
		
		# ah, but this assumes that all Entity objects can be created without parameters
		obj = @klass.new
		obj[:physics].body.p = point
		@space.entities.add obj
		
	end
	
	def update(point)
		# chain into move?
		# maybe it's different depending on the entity spawned?
		# like, selection boxes or text boxes should chain into resize
	end
	
	def cleanup
		
	end
end



end
end