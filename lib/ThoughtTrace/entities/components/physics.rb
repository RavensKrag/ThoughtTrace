module ThoughtTrace
	module Components


class Physics < Component
	interface_name :physics
	
	
	attr_reader :body, :shape
	
	def initialize(parent, body, shape)
		# super() # Set up state machine
		
		@body = body
		@shape = shape
		@shape.obj = parent
	end
	
	def mirror(other)
		@body = other.body
		@shape = other.shape
	end
	
	
	# return the center of the shape in world space
	def center
		# NOTE: not all shapes define "center" as of yet. currently, it is just Rect
		@body.local2world @shape.center
	end
	
	
	
	
	def update
		
	end
	
	# Render collision geometry
	def draw(color, z=0)
		@shape.draw color, z
	end
	
	
	# move this entity such that the point A in local space, lines up with the point B in world space
	def foo(local_point, world_point)
		# move to desired world position
		# and then counter-steer based on local-space coordinate
		# (basically, interpret the local point as a delta for counter-steering)
		@body.p = world_point
		@body.p -= local_point
	end
end



end
end