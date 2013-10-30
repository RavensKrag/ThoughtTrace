module TextSpace
	class PanCamera < Action
		bind_to :middle_click
		
		def click(selected)
			# Establish basis for drag
			@pan_basis = @mouse.position_in_world
		end
		
		def drag(selected)
			# Move view based on mouse delta between the previous frame and this one.
			mouse_delta = @mouse.position_in_world - @pan_basis
			
			$window.camera.position -= mouse_delta
			
			@pan_basis = @mouse.position_in_world
		end
		
		def release(selected)
			
		end
	end
end