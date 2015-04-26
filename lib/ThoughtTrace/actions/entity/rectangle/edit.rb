module ThoughtTrace
	class Rectangle
		module Actions


# Change dimensions of Rectangle by using 9-slice style transformation
# No aspect ratio locking.
class Edit < ThoughtTrace::Actions::BaseAction
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
		
		
		
		# all 9 slices in order:
		# left to right, top to bottom.
		@type          = nil # type of transform
		@vert_indicies = nil # affected verts
		
		@type, @vert_indicies = 
			case [x,y]
				
				when [-1, -1]
					[:vert,     [3]]
				
				when [ 0, -1] # top
					[:edge,     [2,3]]
				
				when [ 1, -1]
					[:vert,     [2]]
				
				when [-1,  0] # left
					[:edge,     [3,0]]
				
				when [ 0,  0]
					[:center,   []]
				
				when [ 1,  0] # right
					[:edge,     [1,2]]
				
				when [-1,  1]
					[:vert,     [0]]
				
				when [ 0,  1] # bottom
					[:edge,     [0,1]]
				
				when [ 1,  1]
					[:vert,     [1]]
				
			end
		
		
		@direction = CP::Vec2.new(x,y)
		
		
		
		
		@original_verts    = @entity[:physics].shape.verts
		@original_offset   = @entity[:physics].shape.instance_variable_get(:@offset).clone
		@original_position = @entity[:physics].body.p.clone
		
		shape = @entity[:physics].shape
		@original_width  = shape.width
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
			
			verts = @original_verts.collect{ |vec|  vec.clone  }
			
			case @type
				when :edge
					# scale the edge along the axis shared by it's verts
					a,b = @vert_indicies.collect{|i| verts[i] }
					axis = ( a.x == b.x ? :x : :y )
					puts axis
					
					
					@vert_indicies.each do |i|
						eval "verts[#{i}].#{axis} += delta.#{axis}"
					end
					
				when :vert
					# this is just for debug. not intended behavior yet
					@vert_indicies.each do |i|
						verts[i] += delta
					end
				when :center
					
			end
			
			
			width  = 20
			height = 20
			
			# limit minimum size (like a clamp, but lower bound only)
			width  = MINIMUM_DIMENSION if width  < MINIMUM_DIMENSION
			height = MINIMUM_DIMENSION if height < MINIMUM_DIMENSION
		
		
		@width     = width
		@height    = height
		@new_verts = verts
		@offset    = CP::Vec2.new(0,0)
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		# @entity.resize!(@width, @height, @anchor)
		@entity[:physics].shape.set_verts!(@new_verts, @offset)
		
		
		# w = @width
		# h = @height 
		# @entity[:physics].shape.instance_eval do
		# 	@width  = w
		# 	@height = h
		# end
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@entity[:physics].shape.set_verts!(@original_verts, @original_offset)
		
		
		w = @original_width
		h = @original_height
		@entity[:physics].shape.instance_eval do
			@width  = w
			@height = h
		end
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
		# TODO: should visualize margins on mouseover or something. By the time you have activated the edit action, you already have to know kinda where the margin is.
		
		# NOTE: currently visualization changes, but actual margins are always constant.
		
		# @a ||= CP::Vec2.new(0,0)
		# @b ||= CP::Vec2.new(0,0)
		# ThoughtTrace::Drawing.draw_line(
		# 	$window,
		# 	@a,@b,
		# 	thickness:20, z_index:100000
		# )
		
		
		
		color  = Gosu::Color.argb(0xffFFFF00)
		weight = 2
		z      = 1000
		
		
		w = @entity[:physics].shape.width
		h = @entity[:physics].shape.height
		
		
		# TODO: need margins to shrink as size gets really small
		# transform progression of the smaller of the two sides
		# into a bounded linear quantized sequence, and
		# transform that into super-linear final output sequence
		min_side = [w,h].min
		i = Math.sqrt(min_side/2) # approx of the inverse function of the side progression?
		
		seq = [1,2,3,5,8,13,25]   # limit of this sequence should ideally be MARGIN (currently 20)
		
		max_i = seq.length - 1
		i = max_i if i > max_i
		
		margin = seq[i]
		
		m = margin
		
		
		
		xL = 0
		xa = m
		xb = w-m
		xR = w
		
		yT = 0
		ya = m
		yb = h-m
		yB = h
		
		
		[
			[[xa,yT], [xa,yB]],
			[[xb,yT], [xb,yB]],
			[[xL,ya], [xR,ya]],
			[[xL,yb], [xR,yb]]
		].each do |a, b|
			
			$window.translate *@entity[:physics].body.p.to_a do
			
				a = CP::Vec2.new(*a)
				b = CP::Vec2.new(*b)
				ThoughtTrace::Drawing.draw_line(
					$window,
					a,b,
					color:color, thickness:weight, line_offset:0.5, z_index:z
				)
				
			end
			
			
		end
	end
	
	
	
	
	
	
	private
	
	def clamp_dimensions(verts)
		# limit minimum size (like a clamp, but lower bound only)
		width  = MINIMUM_DIMENSION if width  < MINIMUM_DIMENSION
		height = MINIMUM_DIMENSION if height < MINIMUM_DIMENSION
	end
	
	
	def radial_scaling(point, delta, width, height)
		# ===== Radial Scaling =====
		# scale about the center
		
		# Sign-age of scale is relative to center of rectangle
		# towards center is negative (shrinking)
		# away from center is positive (growing)
		
		
		# --- Magnitude of transform
		# find vector starting from center, and going towards the current point
		center = @entity[:physics].center
		center_to_point = point - center
		radial_axis = center_to_point.normalize
		
		# NOTE: possible crash if 'center' and 'point' are EXACTLY the same
		# ( likelihood is extremely low, but still want to safeguard against it )
		
		
		# displacement in local space along the radial vector
		radial_delta = delta.project(radial_axis)
		radial_displacement = radial_delta.length
		
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
		
		
		
		# this should grab edge movement only, and leave vertex movement unrestricted
		# if (@direction.x == 0) ^ (@direction.y == 0)
		# 	delta = delta.project(@direction)
		# end
		# NOTE: you don't need this, as long as you have the conditional guards on the axis scaling
		
		
		
		# Horizontal Stretch
		if @direction.x != 0
			delta.x *= -1 if @direction.x < 0
			width  += delta.x
		end
		
		# Vertical Stretch
		if @direction.y != 0
			delta.y *= -1 if @direction.y < 0
			height += delta.y
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