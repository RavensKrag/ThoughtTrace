module ThoughtTrace
	class Circle
		module Actions


class Resize < Action
	def initialize(space, stash, entity)
		super(space, stash, entity)
	end
	
	
	# called on first tick
	def setup(point)
		# mark the initial point for reference
		@origin = point
		
		@original_radius = @entity.radius
	end
	
	# return two values: past and future used by Memento
	# called each tick
	def update(point)
		# Alter the size of the circle by an amount equal to the radial displacement
		# Away from the center is positive,
		# towards the center is negative.
		
		displacement = point - @origin
		
		# project displacement along the radial axis
		center = @entity[:physics].body.p.clone
		r = (point - center).normalize
		
		radial_displacement = displacement.project(r)
		magnitude = radial_displacement.length
		
		# flip sign if necessary
		magnitude = -magnitude unless displacement.dot(r) > 0
		
		
		
		# limit minimum size
		radius = @original_radius + magnitude
		radius = MINIMUM_DIMENSION if radius < MINIMUM_DIMENSION
		
		
		
		return @original_radius, radius
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
	class Memento < Action::Memento
		# set future state
		def forward
			@entity.resize(@future)
		end
		
		# set past state
		def reverse
			@entity.resize(@past)
		end
	end
end



end
end
end