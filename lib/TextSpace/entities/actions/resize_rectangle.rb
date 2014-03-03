module TextSpace
	module Actions


class ResizeRectangle < Action
	interface_name :resize
	components :physics
	
	
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
		margin = 20
		top_right = @components[:physics].shape.top_right_vert
		bottom_left = @components[:physics].shape.bottom_left_vert
		
		
		vec = @components[:physics].body.world2local point
		
		# TODO: detect corners as well
		region =	if		vec.x.between? top_right.x - margin, top_right.x
						:right
					elsif	vec.x.between? bottom_left.x, bottom_left.x + margin
						:left
					elsif	vec.y.between? top_right.y - margin, top_right.y
						:top
					elsif	vec.y.between? bottom_left.y, bottom_left.y + margin
						:bottom
					else
						# must be in the shape somewhere
						:center
					end
		
		@region = region
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
		
		displacement = @origin - point
		
			angle = displacement.to_angle
			magnitude = displacement.length
			
			
			center = @components[:physics].shape.center
			point_in_local = @components[:physics].body.world2local point
			
			# rescale in the direction specified by @region
			# whether the distance is positive or negative depends on the displacement
			# displacement towards the center of the shape is negative,
			# displacement towards the outside of the shape is positive
			# figure out direction by comparing displacement to (center of shape to point)
			
			if @region == :right or @region == :left
				if @region == :right
					if point_in_local.x < center.x
						# invert sign
						magnitude *= -1
					end
				elsif @region == :left
					if point_in_local.x > center.x
						# invert sign
						magnitude *= -1
					end
				end
				
				
				
				@components[:physics].shape.width += magnitude
				
				
			elsif @region == :top or @region == :bottom
				
			else
				
			end
			
			
			
			# @components[:physics].resize angle, magnitude
			# need more information than that
			# for things like rectangles,
			# it's important where the original click occurred,
			# so that you can tell one edge drag from another.
			
		@origin = point
		
		
		
		
		
		
		# scale in the direction of the given region (left, top right, etc)
		# by the magnitude of displacement
		# if the region is :center, perform uniform scale
	end
	
	def cleanup
		super()
		
		
	end
end



end
end