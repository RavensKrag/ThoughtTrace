module TextSpace
	module Actions


class ResizeText < Action
	interface_name :resize
	components :physics, :style
	
	
	MARGIN = 50
	MINIMUM_FONT_HEIGHT = 10
	
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
			
			
			# Scale either vertically (changing font height)
			# or horizontally (changing target width, and deriving font height from that)
			
			
			# rescale in the direction specified by @direction vector
			# whether the distance is positive or negative depends on the displacement
			# displacement towards the center of the shape is negative,
			# displacement towards the outside of the shape is positive
			# figure out direction by comparing displacement to the @direction vector
			
			
			# flip sign to negative if necessary
			magnitude *= -1 if local_displacement_direction.dot(@direction) < 0
			
			
			
			# still using 9-slice resize code from rectangle
			# what should be done on diagonal resize?
				# should you just not do anything?
				# should the regions be redesigned so there is no diagonal resize region?
				# just resize vertical?
					# all text resizes change both the width and height of the hitbox
			
			
			
			if @direction.y != 0
				# Vertical Scaling
				
				height = @components[:style][:height]
				height += magnitude
				
				height = MINIMUM_FONT_HEIGHT if height < MINIMUM_FONT_HEIGHT
				
				@components[:style][:height] = height
				
				
				# TODO: find a way to make hitbox resize automatically when font size changes
				@entity.resize!
			
			elsif @direction.x != 0
				# Horizontal Scaling
				
				height = @components[:style][:height]
				target_width = @components[:physics].shape.width + magnitude
				
				
				# guess and check heights until you get pretty close to the target width
				
				width_tolerance = 10
				
				delta =	if magnitude > 0
							# positive
							# looking for bigger size
							# current height is smallest possible value
							1
						elsif magnitude < 0
							# negative
							# looking for smaller size
							# current height is largest possible value
							-1
						else
							return
							0
						end
				
				
				begin
					height += delta
					width = @entity.font.width(@entity.string, height)
				end until width >= target_width - width_tolerance
				
				
				
				
				if height >= MINIMUM_FONT_HEIGHT
					@components[:physics].shape.resize!(width, height)
					@components[:style][:height] = height
				end
			end
			
			
			# shape always expands in the positive direction of the adjusted axis
			# thus, if you stretch left or down, you need to shift the center
			
			# need to adjust the position of the body
			# so it appears only the edited edge is moving
			@components[:physics].body.p.x -= magnitude if @direction.x < 0
			@components[:physics].body.p.y -= magnitude if @direction.y < 0
			
			
		@origin = point
	end
	
	def cleanup
		super()
		
		
	end
end



end
end