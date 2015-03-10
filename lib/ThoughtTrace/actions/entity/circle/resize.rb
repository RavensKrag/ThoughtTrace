module ThoughtTrace
	class Circle
		module Actions


class Resize < ThoughtTrace::Actions::BaseAction
	MINIMUM_DIMENSION = 10
	
	initialize_with :entity
	
	# called on first tick
	def press(point)
		# mark the initial point for reference
		@origin = point
		
		@original_radius = @entity.radius
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		# Alter the size of the circle by an amount equal to the radial displacement
		# Away from the center is positive,
		# towards the center is negative.
		
		displacement = point - @origin
		
		# project displacement along the radial axis
		center = @entity[:physics].body.p.clone
		r = (point - center).normalize
		
		radial_displacement = displacement.project(r)
		magnitude = radial_displacement.length
		
		# flip sign if necessary
		magnitude = -magnitude unless displacement.dot(r) > 0
		
		
		
		# limit minimum size
		radius = @original_radius + magnitude
		radius = MINIMUM_DIMENSION if radius < MINIMUM_DIMENSION
		
		
		@radius = radius
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@entity.resize!(@radius)
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@entity.resize!(@original_radius)
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		
	end
end



end
end
end