module ThoughtTrace
	module Queries


class CollisionManager
	def initialization(space)
		@space = space
		
		@collision_handler = ThoughtTrace::Queries::CollisionHandler.new
	end
	
	
	
	def call
		collision_types = find_collision_types()
		collision_types.delete :query # want to process every type, other than :query
		collision_types.each{|type|  bind(type) }
	end
	
	alias [] :call # lambda-style square-bracket function call
	
	
	
	
	
	
	def find_collision_types
		# first draft
		@space.entities
			.select{ |e|  e[:physics] }
			.collect{|e|  e[:physics].shape.collision_type }
			.uniq!
	end
	
	
	def bind(other_collision_type)
		# could potentially have to bind this thing between multiple pairs
		@space.add_collision_handler(
			:query, other_collision_type,
			@collision_handler
		)
	end
end



end
end