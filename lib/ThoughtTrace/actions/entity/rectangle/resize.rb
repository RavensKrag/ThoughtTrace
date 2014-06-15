module ThoughtTrace
	class Rectangle
		module Actions


class Resize < Entity::Actions::Action
	MARGIN = 50
	MINIMUM_DIMENSION = 10
	
	# called on first tick
	def setup(point)
		# mark the initial point for reference
		@origin = point
		
		# test in which region of the shape the point lies
		# ASSUMPTION: point is already known to lie within the shape
		
		
		# convert to local space
		# find distance to edges using local x,y coordinate system
			# don't need to actually use distance formula,
			# and can get distance even if there's rotation in the shape.
		top_right = @entity[:physics].shape.top_right_vert
		bottom_left = @entity[:physics].shape.bottom_left_vert
		
		
		local_point = @entity[:physics].body.world2local point
		
		
		
		
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
		
		
		
		# TODO: remove @original_width/height if unnecessary
		@original_width = @entity[:physics].shape.width
		@original_height = @entity[:physics].shape.height
		
		
		@original = [@original_width, @original_height, nil]
	end
	
	# return two values: past and future used by Memento
	# called each tick
	def update(point)
		local_origin = @entity[:physics].body.world2local @origin
		local_point = @entity[:physics].body.world2local point
		local_displacement = local_point - local_origin
			
			
			return if local_displacement.zero? # short circuit when there is no movement
			
			
			# only use the component of the displacement in the direction of the edited component
			# ie) the direction of a corner, or one of the edges
			# this is NOT currently the value of the @direction vector
			# that merely shows which edges should be scaled
			# thus, the current implementation scales corners faster
				# (diagonal straight-line distance is shorter than taxi-cab distance)
			
			# get axes
			width, height = @original
			
			if @direction.zero?
				# ===== Uniform Scale =====
				# scale about the center
				
				# Sign-age of scale is relative to center of rectangle
				# towards center is negative (shrinking)
				# away from center is positive (growing)
				
				
				# --- Magnitude of transform
				# find vector starting from center, and going towards the current point
				center = @entity[:physics].shape.center
				center_to_point = local_point - center
				radial_axis = center_to_point.normalize
				
				
				
				# displacement in local space along the radial vector
				radial_displacement = local_displacement.project(radial_axis).length
				
				# flip sign to negative if necessary
				same_direction = local_displacement.dot(radial_axis) > 0
				radial_displacement *= -1 unless same_direction
				
				
				
				
				# --- Apply magnitude of transform in appropriate directions
				# multiply by two, because resizing is happening in two directions at once
				width  += radial_displacement * 2
				height += radial_displacement * 2
			else
				# ===== Scale in one direction only =====
				# pin down part (edge or vert) of the rectangle, and stretch out the rest
				
				# rescale in the direction specified by @direction
				# displacement towards the center of the shape is negative,
				# displacement towards the outside of the shape is positive
				
				projection = local_displacement.project(@direction)
				
				
				# Compute new dimensions
				if projection.x != 0
					# Horizontal Stretch
					
					if @direction.x < 0
						width -= projection.x
					else
						width += projection.x
					end
				end
				if projection.y != 0
					# Vertical Stretch
					
					if @direction.y < 0
						height -= projection.y
					else
						height += projection.y
					end
				end
			end
			
			
			
			# limit minimum size (like a clamp, but lower bound only)
			width  = MINIMUM_DIMENSION if width  < MINIMUM_DIMENSION
			height = MINIMUM_DIMENSION if height < MINIMUM_DIMENSION
		
		
		
		current = [width, height, anchor_point()]
		
		return @original, current
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw(point)
		
	end
	
	
	
	# perform the transformation here
	# by encapsulating the transform in this object,
	# it becomes easy to redo / undo actions as necessary
	# (Consider better name. Current class name derives from a design pattern.)
	# (this class also has ideas from the command pattern, though)
	# TODO: consider that writing new versions of Memento may be unnecessary if the Memento always passes the @future / @past value(s) to #forward / #reverse. That's not currently what's happening necessarily, but that might be a good direction to go in.
	ParentMemento = self.superclass.const_get 'Memento'
	class Memento < ParentMemento
		# set future state
		def forward
			width, height, anchor = @future
			@entity.resize!(width, height, anchor)
		end
		
		# set past state
		def reverse
			width  = @past[0]
			height = @past[1]
			anchor = @future[2]
			
			
			# use anchor from the future instead
			# anchor on @past is always going to be nil
			# because the notion of an anchor in that context makes no sense,
			# and thus can not be set
			
			@entity.resize!(width, height, anchor)
		end
	end
	
	
	private
	
	def anchor_point
		# normalized anchor
		# NOTE: remember that the anchor specifies the amount of counter-steering
		# TODO: allow for more analog anchor specification
		# TODO: consider anchoring based on where the initial point of context was.
		x = 
			if @direction.x > 0
				# pos
				0.0
			elsif @direction.x < 0
				# neg
				1.0
			else
				# zero
				# center
				0.5
			end
		y = 
			if @direction.y > 0
				# pos
				0.0
			elsif @direction.y < 0
				# neg
				1.0
			else
				# zero
				0.5
			end
		
		return CP::Vec2.new(x,y)
	end
end



end
end
end