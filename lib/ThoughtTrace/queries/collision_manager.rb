require 'set'

module ThoughtTrace
	module Queries


class CollisionManager
	def initialization(space)
		@space = space
		
		@collision_handler = ThoughtTrace::Queries::CollisionHandler.new space
		
		@known_types = find_collision_types
	end
	
	
	
	def call
		@known_types = find_collision_types
		@known_types.delete ThoughtTrace::Queries::COLLISION_TYPE # want to process all other types
		@known_types.each{|type|  bind(type) }
	end
	
	alias [] :call # lambda-style square-bracket function call
	
	
	
	
	
	
	
	def add(collision_type)
		unless @known_types.include? collision_type
			bind(collision_type)
			
			@known_types.add collision_type
		end
	end
	
	def delete(collision_type)
		@space.remove_collision_handler ThoughtTrace::Queries::COLLISION_TYPE, collision_type
		
		
		@known_types.delete collision_type
	end
	
	
	
	
	
	
	
	def find_collision_types
		@space.entities
			.select{ |e|  e[:physics] }
			.collect{|e|  e[:physics].shape.collision_type }
			.to_set
	end
	
	
	def bind(other_collision_type)
		# could potentially have to bind this thing between multiple pairs
		@space.add_collision_handler(
			ThoughtTrace::Queries::COLLISION_TYPE, other_collision_type,
			@collision_handler
		)
	end
end



end
end