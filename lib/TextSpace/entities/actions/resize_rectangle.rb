module TextSpace
	module Actions


class ResizeRectangle < Action
	interface_name :resize
	components :physics
	
	
	MARGIN = 50
	MINIMUM_DIMENSION = 10
	
	def setup(stash, point)
		super(stash, point)
		
		# mark the initial point for reference
		@origin = point
		
		# test in which region of the shape the point lies
		# ASSUMPTION: point is already known to lie within the shape
		
		
		# convert to local space
		# find distance to edges using local x,y coordinate system
			# don't need to actually use distance formula,
			# and can get distance even if there's rotation in the shape.
		top_right = @components[:physics].shape.top_right_vert
		bottom_left = @components[:physics].shape.bottom_left_vert
		
		
		local_point = @components[:physics].body.world2local point
		
		
		
		
		# Figure out what sector out of nine the point is in
		# (top, bottom, right, left, top_right, top_left, bottom_right, bottom_left, center)
		x =	if local_point.x.between? top_right.x - MARGIN, top_right.x
				# :right
				1
			elsif local_point.x.between? bottom_left.x, bottom_left.x + MARGIN
				# :left
				-1
			else
				0
			end
		
		y =	if local_point.y.between? top_right.y - MARGIN, top_right.y
				# :top
				1
			elsif local_point.y.between? bottom_left.y, bottom_left.y + MARGIN
				# :bottom
				-1
			else
				0
			end
		
		@direction = CP::Vec2.new(x,y)
		
		
		
		# Reshape diagonals to point at the actual corners,
		# not just the corners of an ideal square
		if x != 0 && y != 0
			@direction.x *= @entity[:physics].shape.width
			@direction.y *= @entity[:physics].shape.height
			
			@direction.normalize!
		end
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
		
		local_origin = @components[:physics].body.world2local @origin
		local_point = @components[:physics].body.world2local point
		local_displacement = local_point - local_origin
			
			
			return if local_displacement.zero? # short circuit when there is no movement
			
			
			# only use the component of the displacement in the direction of the edited component
			# ie) the direction of a corner, or one of the edges
			# this is NOT currently the value of the @direction vector
			# that merely shows which edges should be scaled
			# thus, the current implementation scales corners faster
				# (diagonal straight-line distance is shorter than taxi-cab distance)
			
			
			if @direction.zero?
				# ===== Uniform Scale =====
				# scale about the center
				
				# Sign-age of scale is relative to center of rectangle
				# towards center is negative (shrinking)
				# away from center is positive (growing)
				
				
				# --- Magnitude of transform
				# find vector starting from center, and going towards the current point
				center = @components[:physics].shape.center
				center_to_point = local_point - center
				radial_axis = center_to_point.normalize
				
				
				
				# displacement in local space along the radial vector
				radial_displacement = local_displacement.project(radial_axis).length
				
				# flip sign to negative if necessary
				same_direction = local_displacement.dot(radial_axis) > 0
				radial_displacement *= -1 unless same_direction
				
				
				
				
				# --- Apply magnitude of transform in appropriate directions
				# get axes
				width = @components[:physics].shape.width
				height = @components[:physics].shape.height
				
				# multiply by two, because resizing is happening in two directions at once
				width  += radial_displacement * 2
				height += radial_displacement * 2
				
				# limit minimum size
				width  = MINIMUM_DIMENSION if width  < MINIMUM_DIMENSION
				height = MINIMUM_DIMENSION if height < MINIMUM_DIMENSION
				
				
				@components[:physics].shape.resize!(width, height)
				
				
				
				
				
				# need to adjust the position of the body
				# so it appears only the edited edge is moving
				# (same code from uni-directional code, but apply both directions always)
				@components[:physics].body.p.x -= radial_displacement
				@components[:physics].body.p.y -= radial_displacement
			else
				# ===== Scale in one direction only =====
				# pin down part (edge or vert) of the rectangle, and stretch out the rest
				
				# rescale in the direction specified by @direction
				# displacement towards the center of the shape is negative,
				# displacement towards the outside of the shape is positive
				
				projection = local_displacement.project(@direction)
				
				
				# Compute new dimensions
				width = @components[:physics].shape.width
				height = @components[:physics].shape.height
				
				
				if projection.x != 0
					# Horizontal Stretch
					
					# signed_op = @direction.x < 0 ? :- : :+
					# width = width.send signed_op, projection.x
					if @direction.x < 0
						width -= projection.x
					else
						width += projection.x
					end
					
					# limit minimum
					width = MINIMUM_DIMENSION if width < MINIMUM_DIMENSION
				end
				if projection.y != 0
					# Vertical Stretch
					
					if @direction.y < 0
						height -= projection.y
					else
						height += projection.y
					end
					
					# limit minimum
					height = MINIMUM_DIMENSION if height < MINIMUM_DIMENSION
				end
				
				# Set dimensions
				@components[:physics].shape.resize!(width, height)
				
				
				# NOTE: Setting the height and width independently is actually kinda weird. The operations both require recomputing the geometry, so doing it this way means the geometry could be computed twice.
				
				
				
				# shape always expands in the positive direction of the adjusted axis
				# thus, if you stretch left or down, you need to shift the center
				
				# need to adjust the position of the body
				# so it appears only the edited edge is moving
				
				# Changed to always adding the component of direction, because it's unsigned
				@components[:physics].body.p.x += projection.x if @direction.x < 0
				@components[:physics].body.p.y += projection.y if @direction.y < 0
			end
			
			
		@origin = point
	end
	
	def cleanup
		super()
		
		
	end
end



end
end