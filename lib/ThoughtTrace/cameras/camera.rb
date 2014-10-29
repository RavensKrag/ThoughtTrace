module ThoughtTrace


class Camera < Rectangle
	def initialize
		# Always set the origin of the shape to the upper right corner.
		# The current systems rely on counter-steering, rather than moving the shape's origin.
		# The origin can be moved during resize, but that complicates things.
		# If you need to know the center point of any shape, you should ask for the center.
		
		# (initial dimensions are arbitrary. camera will be resized on bind)
		width = 100
		height = 100
		
		
		super(width, height)
		
		
		# Set initial point for the camera to look at
		self.look_at CP::Vec2.new(0,0)
	end
	
	
	
	
	# center the camera on the designated spot
	def look_at(point)
		center = @components[:physics].shape.center # center point in local-space 
		
		@components[:physics].body.p = point - center
	end
	
	# camera should remain centered on the same spot, but should be resized to match the window
	def bind_to_window(window)
		# TODO: update this bind method to accommodate drawing to subsection of the window (ie. viewports) rather than whole windows, if updating is necessary. This code may just work for that purpose as well without modification.
		
		point = self.center
		
		@window = window
		
		width  = @window.width
		height = @window.height
		self.resize!(width, height, CP::Vec2.new(0.5, 0.5))
		
		
		self.look_at(point)
	end
	
	
	# retrieve the center point of the camera in world-space
	def center
		centroid = @components[:physics].shape.center
		body = @components[:physics].body
		
		return body.local2world centroid
	end
	
	
	
	
	
	def update
		
	end
	
	def draw
		vec = self.offset
		
		@window.translate -vec.x, -vec.y do
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
	
	
	
	
	# Convert from screen coordinates to world space coordinates.
	# Similar to the raycasting used for mouse picking.
	# (world to screen transform performed in #draw. better to transform on GPU.)
	def screen2world(vec)
		# TODO: make sure this still works when viewports are implemented. It might only work with render contexts that span the entire window. Or rather, it might only work with points relative to the window's origin, and not the camera origin? not totally sure
		
		return vec + offset
	end
end



end