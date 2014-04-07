module ThoughtTrace
	module Actions


class ResizeCircle < Action
	interface_name :resize
	components :physics
	
	MINIMUM_DIMENSION = 10
	
	def setup(stash, point)
		super(stash, point)
		
		# mark the initial point for reference
		@origin = point
		
	end
	
	def update(point)
		super(point)
		
		# apply one tick of resize change
		# each time this method is called, one d_size / d_t should be applied
		
		# can think of this method as a loop
		# each time the game loop hits this method,
		# it will advance the resizing algorithm by one tick
		
		# this method has circular flow
		# because it will be called every tick
		# as long as the button is held
		
		
		# Alter the size of the circle by an amount equal to the radial displacement
		# Away from the center is positive,
		# towards the center is negative.
		
		displacement = @origin - point
		
		# project displacement along the radial axis
		center = @components[:physics].body.p.clone
		r = (point - center).normalize
		
		radial_displacement = displacement.project(r)
		magnitude = radial_displacement.length
		
		# flip sign if necessary
		magnitude = -magnitude unless displacement.dot(r) < 0
		
			shape = @components[:physics].shape
			
			# limit minimum size
			radius = shape.radius + magnitude
			radius = MINIMUM_DIMENSION if radius < MINIMUM_DIMENSION
			
			shape.set_radius! radius
			
		@origin = point
	end
	
	def cleanup
		super()
		
		
	end
end



end
end