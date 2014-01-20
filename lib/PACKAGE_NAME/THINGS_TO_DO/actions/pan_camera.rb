module TextSpace
	class PanCamera < Action
		def press
			super(nil)
		end
		
		private
		
		def on_press(obj)
			# this "obj" will always be nil, as no object is necessary,
			# but this interface must be left as is, to maintain similarity with other Actions
			
			# Establish basis for drag
			@pan_basis = @mouse.position_in_world
		end

		def on_hold
			# Move view based on mouse delta between the previous frame and this one.
			mouse_delta = @mouse.position_in_world - @pan_basis
			
			$window.camera.position -= mouse_delta
			
			@pan_basis = @mouse.position_in_world
		end

		def on_release
			
		end
	end
end