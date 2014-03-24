module ThoughtTrace


class Camera < Entity
	def initialize
		super()
		
		
	
		# Position of upper left corner, relative to @position
		offset = CP::Vec2.new(-$window.width/2, -$window.height/2)
		
		
		# TODO: should probably set camera dimensions more intelligently
		width = $window.width
		height = $window.height
		
							body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
							shape = CP::Shape::Rect.new body, width, height, offset
		add_component	ThoughtTrace::Components::Physics.new self, body, shape
		
		add_action ThoughtTrace::Actions::Move.new self
		
		
		
		# Center position
		@components[:physics].body.p = CP::Vec2.new($window.width/2, $window.height/2)
	end
	
	def update
		
	end
	
	def draw
		vec = self.offset
		
		$window.translate -vec.x, -vec.y do
			yield
		end
	end
	
	# Offset for screen coordinates to camera space
	def offset
		# get the top left vert of the shape,
		# and use it's position in world space
		
		
		body = @components[:physics].body
		shape = @components[:physics].shape
		
		
		# this verts in rect are assigned starting from the top left, and continuing CW
		# but that assumes that origin is bottom left, x+ right and y+ up
		# since the origin is in the upper-left, and y+ is down,
		# we want the vert on the bottom, and not the top
		# (yeah, it's weird)
		vec = body.local2world shape.bottom_left_vert
		
		return vec
	end
end



end