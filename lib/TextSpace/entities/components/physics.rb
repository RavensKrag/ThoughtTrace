module TextSpace
	module Components


class Physics < Component
	interface_name :physics
	
	def initialize(parent, body, shape)
		# super() # Set up state machine
		
		@body = body
		@shape = shape
		@shape.obj = parent
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