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
end



end
end