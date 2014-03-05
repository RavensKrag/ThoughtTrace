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
			return if local_displacement.zero? # short circuit when there is no movement
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
			
			
			vec_before = @components[:physics].shape.top_right_vert
			
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
				
				
				
				width_tolerance = 20
				variance_tolerance = 10
				
				max_size = 100000
				min_size = 20
				
				size_step = 1
				
				
				# initial probing of size using typography rules,
				# then guess and check to get a more precise measurement
				ems_per_char = 0.625
				
				
				heuristic_height = nil
				if magnitude > 0
					# positive
					# growing
					
					i = @components[:style][:height]
					while i < max_size do
						i += size_step
						
						
						heuristic_height = i
						em_width = @entity.font.width("m", heuristic_height)
						heuristic_width = @entity.string.length * em_width * ems_per_char
						
						break if heuristic_width > target_width + width_tolerance
					end
				elsif magnitude < 0
					# negative
					# shrinking
					
					i = @components[:style][:height]
					while i > min_size do
						i -= size_step
						
						
						heuristic_height = i
						em_width = @entity.font.width("m", heuristic_height)
						heuristic_width = @entity.string.length * em_width * ems_per_char
						
						break if heuristic_width < target_width - width_tolerance
					end
				else
					raise "Magnitude of the displacement should not be zero: #{local_displacement} => #{magnitude}"
					
					# TODO: need to ignore displacements of 0.0
					# maybe there should be a movement threshold?
					# but the only real problem is if there's no motion at all
					
					# should probably guard rectangle resize against that as well
				end
				
				
				
				
				
				# narrow the range some more
				# the limits of the search should now be the desired width,
				# and the result of the heuristic pass
				
				# iterate along range of possible heights, and pick the best possible value
				
				# possible heights should be bounded by
					# the original height of the text object
					# the heuristic search for height
				
				
				original_height = @components[:style][:height]
				
				smaller_height = [original_height, heuristic_height].min
				larger_height = [original_height, heuristic_height].max
				
				
				width = nil
				height = original_height
				(smaller_height..larger_height).step(size_step/10.0) do |h|
					# use actual width calculation instead of heuristic this time
					
					new_width = @entity.font.width(@entity.string, h)
					
					break if new_width > target_width
					
					width = new_width
					height = h
				end
				
				
				
				
				if height and width and height >= MINIMUM_FONT_HEIGHT
					@components[:physics].shape.resize!(width, height)
					@components[:style][:height] = height
				end
			end
			
			
			# shape always expands in the positive direction of the adjusted axis
			# thus, if you stretch left or down, you need to shift the center
			
			# need to adjust the position of the body
			# so it appears only the edited edge is moving
			
			# TODO: consider making horizontal offset split relative to initial position of cursor, and not the current position. Current position means that as entity resizes, and the regions thus change size, the type of resizing will change.  It's rather odd.
			
			vec_after = @components[:physics].shape.top_right_vert
			
			offset = vec_after.x - vec_before.x
			
			
			if local_point.x < @components[:physics].shape.width * 1/3 
				# left
				puts "left #{offset}"
				
				@components[:physics].body.p.x -= offset
			elsif local_point.x < @components[:physics].shape.width * 2/3 
				# center
				puts "center"
				
				@components[:physics].body.p.x -= offset / 2
			else
				# right
				puts "right"
				
				# no movement
			end
			# @components[:physics].body.p.x -= magnitude if @direction.x < 0
			
			@components[:physics].body.p.y -= magnitude if @direction.y < 0
			
			
		@origin = point
	end
	
	def cleanup
		super()
		
		
	end
end



end
end