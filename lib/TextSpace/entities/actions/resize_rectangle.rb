module TextSpace
	module Actions


class ResizeRectangle < Action
	interface_name :resize
	components :physics
	
	
	MARGIN = 50
	
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
		
		# TODO: detect corners as well
		region =	if		local_point.x.between? top_right.x - MARGIN, top_right.x
						:right
					
					elsif	local_point.x.between? bottom_left.x, bottom_left.x + MARGIN
						:left
					
					elsif	local_point.y.between? top_right.y - MARGIN, top_right.y
						:top
					
					elsif	local_point.y.between? bottom_left.y, bottom_left.y + MARGIN
						:bottom
					
					else
						# must be in the shape somewhere
						:center
					end
		
		@region = region
		
		
		
		# list of unit vectors that correspond to directions to stretch the rectangle
		directions = {
			:right => CP::Vec2.new(1,0),
			:left => CP::Vec2.new(-1,0),
			:top => CP::Vec2.new(0,1),
			:bottom => CP::Vec2.new(0,-1)
		}
		
		@direction = directions[@region]
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
		
		displacement = point - @origin
		
		
			if @region == :center
				# Uniform Scale
			else
				# Scale in one direction only
				
				magnitude = displacement.length
				
				
				# rescale in the direction specified by @region
				# whether the distance is positive or negative depends on the displacement
				# displacement towards the center of the shape is negative,
				# displacement towards the outside of the shape is positive
				# figure out direction by comparing displacement to a list of unit vectors
				# (trying to calculate midpoints of sides is wasteful)
				# (and because of floating point imprecision, it's totally wrong)
				
				
				local_origin = @components[:physics].body.world2local @origin
				local_point = @components[:physics].body.world2local point
				
				local_displacement = local_point - local_origin
				
				# flip sign to negative if necessary
				magnitude *= -1 if local_displacement.dot(@direction) < 0
				
				
				
				# stretch horizontally or vertically
				if @region == :right or @region == :left
					@components[:physics].shape.width += magnitude
				elsif @region == :top or @region == :bottom
					@components[:physics].shape.height += magnitude
				end
				
				
				
				# shape always expands in the positive direction of the adjusted axis
				# thus, if you stretch left or down, you need to shift the center
				
				# need to adjust the position of the body
				# so it appears only the edited edge is moving
				@components[:physics].body.p.x -= magnitude if @region == :left
				@components[:physics].body.p.y -= magnitude if @region == :bottom
			end
			
			
		@origin = point
	end
	
	def cleanup
		super()
		
		
	end
end



end
end