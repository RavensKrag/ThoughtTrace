module ThoughtTrace
	module Actions


class ResizeText < Action
	interface_name :resize
	components :physics, :style
	
	
	MARGIN = 50
	MINIMUM_FONT_HEIGHT = 10
	
	def setup(stash, point)
		super(stash, point)
		
		# THIS METHOD CONTAINS CODE COPIED FROM resize_rectangle.rb
		
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
			
			# get axes
			
			
			# for text, you always want to end up computing the height,
			# as opposed to the standard rectangle, where you need both width and height
			width = @components[:physics].shape.width
			height = @components[:physics].shape.height
			
		
				# ===== Scale in one direction only =====
				# pin down part (edge or vert) of the rectangle, and stretch out the rest
				
				# rescale in the direction specified by @direction
				# displacement towards the center of the shape is negative,
				# displacement towards the outside of the shape is positive
				
				projection = local_displacement.project(@direction)
				
				
				# Compute new dimensions
				if projection.y != 0
					# Vertical Scaling
					
					if @direction.y < 0
						height -= projection.y
					else
						height += projection.y
					end
				elsif projection.x != 0
					# Horizontal Scaling
					
					# simple ratio solution courtesy of this link
					# http://tech.pro/tutorial/691/csharp-tutorial-font-scaling
					
					
					if @direction.x < 0
						width -= projection.x
					else
						width += projection.x
					end
					
					
					original_width = @components[:physics].shape.width
					ratio = width.to_f / original_width.to_f
					
					height = height * ratio
				end
			
			
			# limit minimum size (like a clamp, but lower bound only)
			height = MINIMUM_FONT_HEIGHT if height < MINIMUM_FONT_HEIGHT
			
			
			
			
			# must clamp new values first before comparing to old values to get proper deltas
			old_width  = @components[:physics].shape.width
			old_height = @components[:physics].shape.height
			
				
				# (use Entity-level resize so that the text drives the hitbox as opposed to the generic rectangle shape resize)
				
				@components[:style][:height] = height
				
				# TODO: find a way to make hitbox resize automatically when font size changes
				@entity.resize!
			
			
			new_width  = @components[:physics].shape.width
			new_height = @components[:physics].shape.height
			
			
			delta_width = old_width - new_width
			delta_height = old_height - new_height
			
			
			
			
			# shape always expands in the positive direction of the adjusted axis
			# thus, if you stretch left or down, you need to shift the center
			# in order to make it feel like the rest of the geometry is firmly planted in place.
			
			# Needs a "center" counter-steering type not present in rectangle resizing
			# because the height and width change together.
			# Center counter-steering maintains the feel that the main edge is moving.
			
			x_offset =	if @direction.x < 0
							# left
							
							delta_width
						elsif @direction.x > 0
							# right
							
							# no movement
							0
						else
							# center
							
							delta_width / 2
						end
			@components[:physics].body.p.x += x_offset
			
			
			y_offset =	if @direction.y < 0
							# bottom
							
							delta_height
						elsif @direction.y > 0
							# top
							
							# no movement
							0
						else
							# center
							
							delta_height / 2
						end
			@components[:physics].body.p.y += y_offset
			
			
			
		@origin = point
	end
	
	def cleanup
		super()
		
		
	end
end



end
end