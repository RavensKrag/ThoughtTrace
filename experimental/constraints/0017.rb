# don't conflate constraints with their visualizations like this it's really bad and gross aaaah

class Constraint
	def initialize(a,b)
		@b = b
		@a = a
		
		
		# physics properties describe a line that links two entities
		# NOTE: probably want to conceal the physics backend as much as possible. Stark contrast with the Entity physics component
		@body  = CP::Body.new(1,1)
		
		
			@a_pos = @a[:physics].center
			@b_pos = @b[:physics].center
			
			verts  = generate_verts @a_pos, @b_pos
			offset = CP::Vec2.new(0,0)
		@shape = CP::Shape::Poly.new @body, verts, offset
		
		
		# NOTE: perhaps all Constraints should be tied to the same body? it doesn't really seem like the body is necessary
		
		
		
		@closure = ConstraintClosure.new
	end
	
	
	
	def update
		# update the visualization
		a_pos = @a[:physics].center
		b_pos = @b[:physics].center
		
		# only update the geometry if the entities have moved since the last update
		if a_pos != @a_pos or b_pos != @b_pos
			@a_pos = a_pos
			@b_pos = b_pos
				
				new_verts = generate_verts @a_pos, @b_pos
				offset    = CP::Vec2.new(0,0)
			@shape.set_verts! new_verts, offset
		end
		
		
		
		
		# logic for when to apply constraint tick
		# and the subsequent application of the tick
		
		
		# the current logic flow works very well for limiting constraints,
		# but will have issues with propagating constraints,
		# as it is currently assumed that all entities get edited through Actions,
		# rather than standard method calls.
		# This is necessary to ensure actions like "stretch to the right" work as expected.
	end
	
	def draw
		# render the line between A and B
		@shape.draw(color, z)
	end
	
	
	
	
	
	# return the dependencies for this constraint
	# each child class of Constraint must define this method
	def foo(a,b)
		[
			a[:physics].height
		]
	end
	
	# execute one tick
	def call(a,b)
		# process A and B to get a value
		# run that value through the closure for further transformation,
		# supplying additional arguments to closure as necessary
		value = a[:physics].height
		value = @closure.call(value)
		
		# NOTE: this can't just be wrapped up in a 'super' call for child classes to call. It's more of a general pattern that needs to be followed. Some classes may not even use the closure object at all.
	end
	
	
	
	
	
	
	
	
	
	
	def position
		# half way between points A and B,
		# ie, the center of the line
		
		@a_pos + @vector*0.5
	end
	
	def length
		@vector.length
	end
	
	def width
		@width
	end
	
	# normalized vector pointing from A to B
	def direction
		@direction
	end
	
	# as in 'surface normal' - the vector orthogonal to the direction vector.
	# tends to point 'up' (positive Y direction)
	def normal
		@normal
	end
	
	
	
	
	private
	
	# here, and A and B are points,
	# as opposed to most other cases in Constraint, where they are Entity objects
	def generate_verts(a,b, thickness:6, line_offset:0.5)
		# code taken from draw_line
		# need to copy here and modify, because this implementation needs to store state
		# as opposed to the standard draw_line, which stores no state.
		# also, this version uses physics data, and the standard draw_line does not.
		
		
		# may want to sort the points by x value, in order to help maintain vertex winding
		a,b = [a, b].sort_by{ |v| v.x  }
		
		
		x = b - a
		
		x_hat = x.normalize
		y_hat = x_hat.perp
		
		thickness = thickness.to_f
		
		delta = (thickness*line_offset)
		
		verts = [
			a + y_hat*delta,
			b + y_hat*delta,
			b - y_hat*delta,
			a - y_hat*delta
		].reverse!
		
		@width     = thickness
		@vector    = x
		@direction = x_hat
		@normal    = y_hat
		
		return verts
	end
end