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
		
		@bound_entity = entity
		
		
		# ===== body
		# -- physics
			# Establish collision callbacks between any Entity, and any Query
			# The collision handler is written very generally
			# Specifics are delegated to each Query object
			
			
			@defaults = {
				:sensor =>         @bound_entity[:physics].shape.sensor,
				:collision_type => @bound_entity[:physics].shape.collision_type
			}
			
			
			@bound_entity[:physics].shape.collision_type = :query
			@bound_entity[:physics].shape.sensor = true
			
			
			
			
		# -- style
			# rather than storing the current style mode for later, the unbind callback will simply make sure that the query style mode is not currently in use, and replace with the default mode if necessary
			
			@bound_entity[:style].mode = :query
			@bound_entity[:style].socket(1, @style)
			@bound_entity[:style].socket(2, default_cascade)
			
			
			# TODO: need a way to retrieve the default cascade
			# TODO: need to make sure that you can nest a cascade inside of another cascade
			
			# with this structure, the query style will always cascade into the default style, even if the default style changes after the binding of the Query to the Entity
			
			# apply yet another style instead of just modifying the default style for the new mode
			# two reasons:
			# 1) allows easy modification of a bunch of objects through one style
			# 2) can modify one Query object independently of the others if you need to (sketching etc)
			# (these are both really two aspects of the same thing)
		
		
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
			# restore chipmunk properties
			@bound_entity[:physics].shape.sensor = @defaults[:sensor]
			@bound_entity[:physics].shape.collision_type = @defaults[:collision_type]
		# -- style
			# eliminate the Query formatting style mode from the cascade
			# and make sure that it is not actively being used to render the Entity
			current_style_mode = @bound_entity[:style].mode
			
			if current_style_mode == :query
				@bound_entity[:style].mode = :default
			end
			
			# do you really want the query style as a new mode? do you not want it to cascade into the other styles defined for the Entity?
			
			# TODO: need method to purge a particular style mode from the Style Component
			
		
		
		# ===== cleanup
		# @bound_entity = nil
		
		return self
	end
end


end
end