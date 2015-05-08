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
	# The name is a reference to the game Twister.
	# Watch this ad if you need an explanation: https://www.youtube.com/watch?v=LIy5pDsuLEY
	def right_hand_on_red(local_point, world_point)
		# move to desired world position
		# and then counter-steer based on local-space coordinate
		# (basically, interpret the local point as a delta for counter-steering)
		# @body.p = world_point
		# @body.p -= local_point
		
		@body.p = world_point - local_point
	end
	
	# sketches of other names:
	# def align(local_point, to:nil) # as in 'align left edge to that place'-
		
		# align edge => point
		# align edge to: point
		# align edge with: point
	
	
	# TODO: maybe use named arguments? not very clear what parameter controls what.
	# ex) 
	# rect.foo(target:point, destination:CP::Vec2.new(30,30))
end



end
end