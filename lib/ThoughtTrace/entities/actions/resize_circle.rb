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
		
		@original_radius = @components[:physics].shape.radius
	end
	
	def update(point)
		super(point)
		
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
		radius = @original_radius + magnitude
		radius = MINIMUM_DIMENSION if radius < MINIMUM_DIMENSION
		
		
		shape.set_radius! radius
	end
	
	def cleanup
		super()
		
		
	end
end



end
end