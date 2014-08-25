module ThoughtTrace
	module Components



class Query < Component
	interface_name :query
	components :physics, :style
	
	def initialize
		
	end
	
	
	
	
	
	
	# connect an Entity to this query
	# TODO: figure out if binding multiple Entities to one Query is permissible or not
	# NOTE: currently, only one Entity can be bound at a time
	
	def on_bind(entity)
		super(entity)
		
		# ===== start
		raise "#{self} already has one Entity bound to it." if @bound_entity
		raise_errors_if_depencies_unmet entity
		
		@bound_entity = entity
		
		
		# ===== body
		# -- physics
			# Establish collision callbacks between any Entity, and any Query
			# The collision handler is written very generally
			# Specifics are delegated to each Query object
			
			# clobbering of collision handlers is acceptable, as it's always the same handler object
			# it is a bit inefficient though
			
			# NOTE: This style allows for Entities with diverse collision_type properties. If the collision type of each Entity is always going to be the same, this step can be performed once in #initialize, rather than being performed on each bind.
			@space.add_collision_handler(
				@@collision_type,
				@bound_entity[:physics].shape.collision_type,
				
				@@collision_handler
			)
			
			@bound_entity[:physics].shape.sensor = true
		# -- style
			# TODO: find a way to revert the style that doesn't clash with things like mouseover
			@bound_entity[:style].mode = :query
			@bound_entity[:style].socket(1, @style)
		
		
		
		# ===== cleanup
		
		return self
	end
	
	
	# Remove the linkage between the Query an it's Entity
	# NOTE: if multiple Entities can be bound to one Query, you should only unbind one. In that case, you would need to specify which Entity you want unbound.
		# I suppose you could take zero args to unbind all?
		# but unbind all is a rather different sort of procedure, so it should be it's own thing
	
	def on_unbind(entity)
		super(entity)
		
		# ===== start
		
		
		
		# ===== body
		# -- physics
			# TODO: consider restoring the shape's previous sensor status instead of forcing false
			@bound_entity[:physics].shape.sensor = false
		# -- style
			@bound_entity[:style].mode = :default
		
		
		# ===== cleanup
		@bound_entity = nil
		
		return self
	end
end


end
end