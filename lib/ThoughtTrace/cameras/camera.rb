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
	
	# TODO: depreciate this method
	# change dimensions, and make sure that the center stays in the same place
	def resize!(width, height)
		# it seems to only be called through #bind_to_window
		# in which case it doesn't even need to really be public?
		# (well, maybe you would want to change camera size in the future. that would be ok.)
		
		
		
		
		# the "position" of a camera is it's center,
		# not the physics position vector, which would be at a corner
		p_world = self.center
		
		
		
		# NOTE: this is actually not that much less efficient than the old resize method that required generating a completely new set of verts. (memory alloc / dealloc can be bad)
		grab_handle = CP::Vec2.new(1,1)
		point       = CP::Vec2.new(width, height)
		@components[:physics].shape.resize!(
			grab_handle, :local_space, point:point, lock_aspect:false,
			minimum_dimension:0
		)
		
		
		
		self.look_at(p_world)
	end
	
	
	
	
	# center the camera on the designated spot
	def look_at(point)
		center = @components[:physics].shape.center # center point in local-space 
		@components[:physics].foo(center, point)
	end
	
	# camera should remain centered on the same spot, but should be resized to match the window
	def bind_to_window(window)
		# TODO: update this bind method to accommodate drawing to subsection of the window (ie. viewports) rather than whole windows, if updating is necessary. This code may just work for that purpose as well without modification.
		@window = window
		
		width  = @window.width
		height = @window.height
		self.resize!(width, height)
		
		self.look_at(CP::Vec2.new(0,0))
	end
	
	
	# retrieve the center point of the camera in world-space
	def center
		@components[:physics].center
	end
	
	
	
	
	
	def update
		
	end
	
	def draw
		@window.translate *(self.offset * -1).to_a do
			yield
		end
	end
	
	# Offset for screen coordinates to camera space
	def offset
		# use the origin of the rectangle for this,
		# which ends up just being the position stored in the body.
		# This works because the position of a Rectangle is at it's local origin,
		# and the shape extends in the +x and +y directions
		
		@components[:physics].body.p.clone
	end
	
	
	
	
	# Convert from screen coordinates to world space coordinates.
	# Similar to the raycasting used for mouse picking.
	# (world to screen transform performed in #draw. better to transform on GPU.)
	def screen2world(vec)
		# TODO: make sure this still works when viewports are implemented. It might only work with render contexts that span the entire window. Or rather, it might only work with points relative to the window's origin, and not the camera origin? not totally sure
		
		@components[:physics].body.local2world(vec)
	end
end



end