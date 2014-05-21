

:left_click => :move
:right_click => :resize


input => list, of, actions


# declaration of what each input is
# is a separate step
# that should probably come before this one
:left_click => [:move]
:right_click => [:resize]




left_click = ActionSelector.new(space, @selection)
left_click => [:move]
# the selector still needs to be driven by actual input somehow, though




# -- higher elements drive lower ones --
# input
	# turns raw button inputs into something more abstract (my library DIS is supposed to do this)
# mouse gestural control thingy (has structure of old action)
	# press-hold-release framework
# string of method calls thingy (new action?)
	# take data from above, feed it to methods
# entity.method
	# manipulate data in the entity
# component
	# namespaced reusable data container for Entity objects
	# contains data that could be reused between disparate Entity types
	# can't really use modules, because you need to initialize stuff
	# could just use a standard object, but the "component" structure allows for dependency management




# methods packaged in the style of old "action"s are unnecessary
# as they can be just packed inside of mixins instead
# 



# NEW ENTITY STYLE
class Circle < Entity
	def initialize
		super()
		
		# TODO: Update geometry when style is updated, and vice versa. (or else maybe width and height shouldn't be stored in Style)
							body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
							shape = CP::Shape::Circle.new body, style[:radius]
		add_component	ThoughtTrace::Components::Physics.new self, body, shape
	end
	
	
	# for rectangular shapes, would have to counter-steer as well
	# there's no real need to counter steer on circles though
	def radius=(r)
		@components[:physics].shape.set_radius! r
	end
	
	def radius
		
	end
end

class Rectangle < Entity
	def initialize
		super()
		
		# TODO: Update geometry when style is updated, and vice versa. (or else maybe width and height shouldn't be stored in Style)
							body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
							shape = CP::Shape::Rect.new body, style[:width], style[:height]
		add_component	ThoughtTrace::Components::Physics.new self, body, shape
	end
	
	
	# need a way to set dimensions, and also counter-steer appropriately
	# (not sure if counter-steering should be based on a origin point that part of the state of the Entity? that seems like a weird thing to do, seeing as how I want to be able to resize based on a bunch of different points, and not just one true center)
	def width=(w)
		@components[:physics].shape.resize!(width, height)
	end
	
	def height=(h)
		@components[:physics].shape.resize!(width, height)
	end
	
	# need a separate resize method, because sometimes you want to set
	# both the height and the width and in one pass
	# it's more efficient that way, after all
	
	def resize(w, h)
		@components[:physics].shape.resize!(width, height)
	end
end

class Text < Rectangle
	def initialize()
		super()
	end
	
	
	# need a way to set dimensions, and also counter-steer appropriately
	# width affects height (and vice versa) for Text
	def width=(w)
		width = w
		height = 10
		
		@components[:physics].shape.resize!(width, height)
	end
	
	def height=(h)
		height = h
		width = 10
		
		@components[:physics].shape.resize!(width, height)
	end
end







# baz ???
# press-hold-release structure of old Action
# arguments are different now though
class Baz
	def setup(stash, entity, point)
		
	end
	
	def update(point)
		
	end
	
	def cleanup
		
	end
end

class Resize < Baz
	# most of this code is taken from resize_rectangle.rb
	def setup(stash, entity, point)
		super(stash, entity, point)
		
		@entity = entity
		@origin = point
		
		@original_width = @components[:physics].shape.width
		@original_height = @components[:physics].shape.height
		
		
		
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
		width = @original_width
		height = @original_height
		
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
			# multiply by two, because resizing is happening in two directions at once
			width  += radial_displacement * 2
			height += radial_displacement * 2
			
			
			
			
			
			
			
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
		
		
		
		
		# must clamp new values first before comparing to old values to get proper deltas
		old_width  = @components[:physics].shape.width
		old_height = @components[:physics].shape.height
		
			
			@components[:physics].shape.resize!(width, height)
		
		
		new_width  = @components[:physics].shape.width
		new_height = @components[:physics].shape.height
		
		
		delta_width = old_width - new_width
		delta_height = old_height - new_height
		
		
		
		# shape always expands in the positive direction of the adjusted axis
		# thus, if you stretch left or down, you need to shift the center
		# in order to make it feel like the rest of the geometry is firmly planted in place.
		
		# (currently does not trigger for uniform scale)
		# (uniform scale counter-steering is being handled the the )
		
		
		# To make the radial resize and the 9-slice style converge,
		# the counter steering should be made explicitly about what is being pinned down
		# for scaling in one direction, that's one edge
		# for scaling at a corner, that's the opposing vert
		# for scaling about the center, it's the center that gets locked down
		
		
		if @direction.x < 0
			@components[:physics].body.p.x += delta_width
		end
		if @direction.y < 0
			@components[:physics].body.p.y += delta_height
		end
		
		
		
		
		
		
		
		
		
		
		
		# TODO: clean up height / width deltas (needed for counter steering code)
		# TODO: clean up counter steering
		# TODO: access properties through the entity pointer, rather than assuming you are within the entity already
		
		
		# not sure if the locked point should be given in local space, or it needs to be transformed into that space from world space
		lockdown_point = CP::Vec2.new(0,0)
		lockdown_point_local = @components[:physics].body.world2local lockdown_point
		
		
		
		
		
		
		
		
		
		# algorithm:
			# measure lockdown point
			# transform shape
			# measure lockdown point - AGAIN
			# compute delta between current and previous lockdown points in world space
			# use world-space delta to displace body so it looks like the lockdown point has not moved
		
		# TODO: check this implementation out again. not sure that the lockdown points are being taken correctly. Especially if it's something like a corner, which is going to change in local-space as a result of the resize operation
		lockdown_point = CP::Vec2.new(0,0) # most commonly a corner, or the center of an edge
		
		pre = measure_lockdown_point lockdown_point
			@components[:physics].shape.resize!(width, height)
		post = measure_lockdown_point lockdown_point
		
		delta = post - pre
		
		@components[:physics].body.p += -delta # move in the inverse direction, to counter-steer
		
		# this is way more complicated than I thought
		# it gets really weird when you try to establish lockdown points
		# relative to the right / top edge of the object, (pos x, pos y)
		# because those edges are moving as a result of resizing
		
		# basically, you're specifying everything relative to origin,
		# even when you don't want to
		# i think?
		# it's confusing
	end
	
	def cleanup
		
	end
	
	
	private
	
	# TODO: rename this method
	def measure_lockdown_point(corner_name_or_vector)
		# TODO: declare this as constant.
		# TODO: declare in CP::Shape::Rect, because this list of symbols is already necessary there
		names_of_verts = [:top_left, :top_right, :bottom_right, :bottom_left]
		
		vec = 
			if names_of_verts.include? corner_name_or_vector
				# given a name of a vert
				@components[:physics].shape.send("#{corner_name_or_vector}_vert")
			elsif corner_name_or_vector.is_a? CP::Vec2
				# given a vert or some other point in local space
				corner_name_or_vector
			else
				# unexpected input
				raise "Expecting either the name of a corner, or a vector. Received #{corner_name_or_vector.inspect}"
			end
		
		
		
		return @components[:physics].body.local2world vec
	end
end

class Move < Baz
	def setup(stash, entity, point)
		super(stash, entity, point)
		
		@initial_point = point
		
		@entity = entity
		@initial_position = @entity.width
	end
	
	def update(point)
		super(point)
		
		delta = point - @initial_point
		
		@entity[:physics].body.p = @initial_position + delta
	end
	
	def cleanup
		
	end
end

# not sure if there should be special variables for things like
	# delta since last frame
	# delta since initialization
# but I'm rather against it
# I don't see why I should create a canonical name
# for something that's easily implemented,
# and doesn't have a good cannon name














# foo ???
# actions are essentially an amalgamation of method calls
# not linked to any one object
# they define an interface to look for, and then a bunch of code to execute around that interface
class ResizeCircle < Action
	interface_name :resize
	
	# methods :
	components :physics
	
	MINIMUM_DIMENSION = 10
	
	def setup(stash, point)
		super(stash, point)
		
		# mark the initial point for reference
		@origin = point
		
		@original_radius = @components[:physics].shape.radius
	end
	
	def update(point)
		super(point)
		
		# Alter the size of the circle by an amount equal to the radial displacement
		# Away from the center is positive,
		# towards the center is negative.
		
		displacement = point - @origin
		
		# project displacement along the radial axis
		center = @components[:physics].body.p.clone
		r = (point - center).normalize
		
		radial_displacement = displacement.project(r)
		magnitude = radial_displacement.length
		
		# flip sign if necessary
		magnitude = -magnitude unless displacement.dot(r) > 0
		
		
		
		# limit minimum size
		radius = @original_radius + magnitude
		radius = MINIMUM_DIMENSION if radius < MINIMUM_DIMENSION
		
		
		@components[:physics].shape.set_radius! radius
	end
	
	def cleanup
		super()
		
		
	end
end


circle.radius = 10












# NEW MODULE SYSTEM
# modules are like namespaces

# ruby syntax
entity.position             # without namespace
entity[:physics].position   # added to namespace
# ideal dsl experimentation
entity.physics:position
entity:physics.position



entity.radius = 10





