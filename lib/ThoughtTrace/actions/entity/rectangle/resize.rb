module ThoughtTrace
	class Rectangle
		module Actions


# Change dimensions of Rectangle by moving edges.
# Aspect ratio is LOCKED.
class Resize < ThoughtTrace::Rectangle::Actions::Edit
	MARGIN = 20 # this currently does nothing
	MINIMUM_DIMENSION = self.superclass::MINIMUM_DIMENSION
	
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
		@entity[:physics].shape.__resize!(
			@grab_handle, :world_space, point:@point, lock_aspect:true,
			minimum_dimension:MINIMUM_DIMENSION
		)
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
	
	def minimum_dimensions(width, height, minimum_dimension)
		minimum_x = nil
		minimum_y = nil
		
		
		if width <= height
			# width limits scaling
			ratio = height / width
			
			minimum_x = minimum_dimension
			minimum_y = minimum_dimension * ratio
		else
			# height limits scaling
			ratio = width / height
			
			minimum_y = minimum_dimension
			minimum_x = minimum_dimension * ratio
		end
		
		return minimum_x, minimum_y
	end
end



end
end
end