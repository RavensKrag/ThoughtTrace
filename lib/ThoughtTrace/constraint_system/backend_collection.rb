module ThoughtTrace
	module Constraints


# stores raw constraint objects
class BackendCollection
	def initialize
		@storage = Hash.new
	end
	
	def add(constraint)
		id = SecureRandom.uuid
		# TOOD: maybe check collision just in case?
		
		@storage[id] = constraint
		
		return id
	end
	
	def [](id)
		return @storage[id]
	end
	
	def []=(id, constraint)
		@storage[id] = constraint
		return constraint
	end
	
	
	# NOTE: this could be a problem, because it exposes all of the stored elements to the outside world at will. That's not the intent, obviously, but it could still be a problem.
	def map_data_to_uuids
		@storage.invert
	end
	
	
	
	
	
	# make a new constraint that is a deep copy of an existing one.
	# used for when you want to create a new Constraint, using an existing one as a base
	def duplicate_constraint(id)
		constraint = self[id]
		
		clone = constraint.class.new(constraint.closure.clone)
		
		self.add(clone)
	end
end



end
end