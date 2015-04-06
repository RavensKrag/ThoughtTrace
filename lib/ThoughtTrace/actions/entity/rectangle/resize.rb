module ThoughtTrace
	class Rectangle
		module Actions


# Change dimensions of Rectangle by moving edges.
# Aspect ratio is LOCKED.
class Resize < ThoughtTrace::Actions::BaseAction
	MARGIN = 20
	MINIMUM_DIMENSION = 25
	
	initialize_with :entity
	
	# called on first tick
	def press(point)
		# mark the initial point for reference
		@origin = point
		
		# test in which region of the shape the point lies
		# ASSUMPTION: point is already known to lie within the shape
		
		
		# convert to local space
		# find distance to edges using local x,y coordinate system
			# don't need to actually use distance formula,
			# and can get distance even if there's rotation in the shape.
		
		local_point = @entity[:physics].body.world2local point
		m = MARGIN # TODO: need margins to shrink as size gets really small
		w = @entity[:physics].shape.width
		h = @entity[:physics].shape.height
		
		# xL = 0
		xa = m
		xb = w-m
		xR = w
		
		# yT = 0
		ya = m
		yb = h-m
		yB = h
		
		
		x = 
			if    local_point.x < xa
				# left
				-1
			elsif local_point.x < xb
				# center
				0
			elsif local_point.x < xR
				# right
				1
			end
		
		y = 
			if    local_point.y < ya
				# top
				-1
			elsif local_point.y < yb
				# center
				0
			elsif local_point.y < yB
				# bottom
				1
			end
		
		# different edge characteristics,
		# slicing from low to high vs chopping the edges from the core
		# only would really effect very small parts of the data, but it's something to think about
		
		# new way favors the low end, old way favors the high end (of a particular axis)
		# don't think you can really tell that about the old code by looking at it though...
		
		
		
		
		
		@direction = CP::Vec2.new(x,y)
		
		
		
		# Reshape diagonals to point at the actual corners,
		# not just the corners of an ideal square
		if x != 0 && y != 0
			@direction.x *= @entity[:physics].shape.width
			@direction.y *= @entity[:physics].shape.height
			
			@direction.normalize!
		end
		
		
		
		
		shape = @entity[:physics].shape
		@original_width = shape.width
		@original_height = shape.height
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		delta = point - @origin
			
			
			return if delta.zero? # short circuit when there is no movement
			
			
			# only use the component of the displacement in the direction of the edited component
			# ie) the direction of a corner, or one of the edges
			# this is NOT currently the value of the @direction vector
			# that merely shows which edges should be scaled
			# thus, the current implementation scales corners faster
				# (diagonal straight-line distance is shorter than taxi-cab distance)
			
			width, height =
				if @direction.zero?
					radial_scaling(point, delta, @original_width, @original_height)
				else
					cartesian_scaling(point, delta, @original_width, @original_height)
				end
			
			# limit minimum size (like a clamp, but lower bound only)
			width  = MINIMUM_DIMENSION if width  < MINIMUM_DIMENSION
			height = MINIMUM_DIMENSION if height < MINIMUM_DIMENSION
		
		
		@width  = width
		@height = height
		@anchor = anchor_point()
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@entity.resize!(@width, @height, @anchor)
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@entity.resize!(@original_width, @original_height, @anchor)
		# use the same anchor from the apply step.
		# this should be enough to reverse the operation.
		# There's no real way to calculate an "inverse anchor",
		# but I don't think that's necessary anyway.
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		# TODO: draw margins to get a better idea of how they should be altered as the shape changes.
		# TODO: consider implementing margin rendering using entities and constraints. Then that data could easily be used to drive the modulation of the margins themselves.
	end
	
	
	
	
	
	
	private
	
	def radial_scaling(point, delta, width, height)
		# ===== Radial Scaling =====
		# scale about the center
		
		# Sign-age of scale is relative to center of rectangle
		# towards center is negative (shrinking)
		# away from center is positive (growing)
		
		
		# --- Magnitude of transform
		# find vector starting from center, and going towards the current point
		center = @entity[:physics].shape.center
		center_to_point = point - center
		radial_axis = center_to_point.normalize
		
		
		
		# displacement in local space along the radial vector
		radial_displacement = delta.project(radial_axis).length
		
		# flip sign to negative if necessary
		same_direction = delta.dot(radial_axis) > 0
		radial_displacement *= -1 unless same_direction
		
		
		
		
		# --- Apply magnitude of transform in appropriate directions
		# multiply by two, because resizing is happening in two directions at once
		width  += radial_displacement * 2
		height += radial_displacement * 2
		
		return width,height
	end
	
	def cartesian_scaling(point, delta, width, height)
		# ===== Cartesian Scaling =====
		# scale along the axes of the rectangle
		
		# pin down part (edge or vert) of the rectangle, and stretch out the rest
		
		# rescale in the direction specified by @direction
		# displacement towards the center of the shape is negative,
		# displacement towards the outside of the shape is positive
		
		
		
		projection = delta.project(@direction)
		
		
		# Compute new dimensions
		if    @direction.x == 0 and @direction.y != 0
			# vertical scaling
			original_height = height
			
			sign = @direction.y < 0 ? -1 : 1
			height += projection.y * sign
			
			ratio = height.to_f / original_height.to_f
			width = width * ratio
		elsif @direction.x != 0 and @direction.y == 0
			# horizontal scaling
			original_width = width
			
			sign = @direction.x < 0 ? -1 : 1
			width += projection.x * sign
			
			ratio = width.to_f / original_width.to_f
			height = height * ratio
		else
			# corner scaling
			
			# Horizontal Stretch
			sign = @direction.x < 0 ? -1 : 1
			width  += projection.x * sign
			
			# Vertical Stretch
			sign = @direction.y < 0 ? -1 : 1
			height += projection.y * sign
		end
		
		
		return width,height
	end
	
	
	
	def anchor_point
		# normalized anchor
		# NOTE: remember that the anchor specifies the amount of counter-steering
		# TODO: allow for more analog anchor specification
		# TODO: consider anchoring based on where the initial point of context was.
		# TODO: consider more complex margin specification. Maybe it should be proportional to size? Not sure in what specify way though.
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