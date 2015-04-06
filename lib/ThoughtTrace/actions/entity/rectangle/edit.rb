module ThoughtTrace
	class Rectangle
		module Actions


# Change dimensions of Rectangle by moving verts around.
# No aspect ratio locking.
class Edit < ThoughtTrace::Rectangle::Actions::Resize
	MARGIN = 20
	MINIMUM_DIMENSION = 10
	
	initialize_with :entity
	
	# called on first tick
	def press(point)
		super(point)
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		super(point)
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		super()
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		super()
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		super(point)
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		super(point)
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		# TODO: draw margins to get a better idea of how they should be altered as the shape changes.
		# TODO: consider implementing margin rendering using entities and constraints. Then that data could easily be used to drive the modulation of the margins themselves.
		super()
	end
	
	
	
	
	
	
	private
	
	def cartesian_scaling(point, delta, width, height)
		# ===== Cartesian Scaling =====
		# scale along the axes of the rectangle
		
		# pin down part (edge or vert) of the rectangle, and stretch out the rest
		
		# rescale in the direction specified by @direction
		# displacement towards the center of the shape is negative,
		# displacement towards the outside of the shape is positive
		
		
		
		# this should grab edge movement only, and leave vertex movement unrestricted
		# if (@direction.x == 0) ^ (@direction.y == 0)
		# 	delta = delta.project(@direction)
		# end
		# NOTE: you don't need this, as long as you have the conditional guards on the axis scaling
		
		
		
		# Horizontal Stretch
		if @direction.x != 0
			delta.x *= -1 if @direction.x < 0
			width  += delta.x
		end
		
		# Vertical Stretch
		if @direction.y != 0
			delta.y *= -1 if @direction.y < 0
			height += delta.y
		end
		
		
		return width,height
	end
end



end
end
end