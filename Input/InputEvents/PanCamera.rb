module MouseEvents
	class PanCamera < EventObject
		bind_to :middle_click
		
		def initialize
			super()
		end
		
		def click(selected)
			# Establish basis for drag
			@pan_basis = position_in_world
		end
		
		def drag(selected)
			# Move view based on mouse delta between the previous frame and this one.
			mouse_delta = position_in_world - @pan_basis
			
			$window.camera.position -= mouse_delta
			
			@pan_basis = position_in_world
		end
		
		def release(selected)
			
		end
	end
end