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
		
		@direction.normalize! unless @direction.zero?
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
			
			
			local_displacement_direction = local_displacement.normalize
			magnitude = local_displacement.length
			
			
			if @direction.zero?
				# ===== Uniform Scale =====
				
				# Sign-age of scale is relative to center of rectangle
				# towards center is negative (shrinking)
				# away from center is positive (growing)
				
				
				# find vector from point to center in local space
				center = @components[:physics].shape.center
				local_point_to_center = local_point - center
				
				# only really need the direction
				direction = local_point_to_center.normalize
				
				
				# flip sign to negative if necessary
				# (same logic from uni-directional, different values)
				magnitude *= -1 if local_displacement_direction.dot(direction) <= 0
				
				
				
				
				width = @components[:physics].shape.width
				height = @components[:physics].shape.height
				
				# multiply by two, because resizing is happening in two directions at once
				width += magnitude * 2
				height += magnitude * 2
				
				# limit minimum size
				width = MINIMUM_DIMENSION if width < MINIMUM_DIMENSION
				height = MINIMUM_DIMENSION if height < MINIMUM_DIMENSION
				
				
				@components[:physics].shape.resize!(width, height)
				
				
				
				
				# need to adjust the position of the body
				# so it appears only the edited edge is moving
				# (same code from uni-directional code, but apply both directions always)
				@components[:physics].body.p.x -= magnitude
				@components[:physics].body.p.y -= magnitude
			else
				# ===== Scale in one direction only =====
				
				# rescale in the direction specified by @region
				# whether the distance is positive or negative depends on the displacement
				# displacement towards the center of the shape is negative,
				# displacement towards the outside of the shape is positive
				# figure out direction by comparing displacement to the @direction vector
				
				
				# flip sign to negative if necessary
				magnitude *= -1 if local_displacement_direction.dot(@direction) < 0
				
				# stretch horizontally or vertically
				if @direction.x != 0
					width = @components[:physics].shape.width
					width += magnitude
					
					# limit minimum
					width = MINIMUM_DIMENSION if width < MINIMUM_DIMENSION
					
					@components[:physics].shape.width = width
				end
				if @direction.y != 0
					height = @components[:physics].shape.height
					height += magnitude
					
					# limit minimum
					height = MINIMUM_DIMENSION if height < MINIMUM_DIMENSION
					
					@components[:physics].shape.height = height
				end
				
				
				# shape always expands in the positive direction of the adjusted axis
				# thus, if you stretch left or down, you need to shift the center
				
				# need to adjust the position of the body
				# so it appears only the edited edge is moving
				@components[:physics].body.p.x -= magnitude if @direction.x < 0
				@components[:physics].body.p.y -= magnitude if @direction.y < 0
			end
			
			
		@origin = point
	end
	
	def cleanup
		super()
		
		
	end
end



end
end