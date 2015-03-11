module InputSystem


class CameraController
	attr_accessor :camera
	
	def initialize(mouse, camera, action_factory)
		@mouse = mouse
		@camera = camera
		
		
		@action_factory = action_factory
	end
	
	
	def press(event_name)
		# extract move action from @camera at this step,
		# in case the camera has been changed since initialization
		@move_action = @action_factory.create(@camera, :move)
		
		
		@move_action.press(@mouse.position_on_screen)
	end
	
	def hold(event_name)
		@move_action.hold(@mouse.position_on_screen)
	end
	
	def release(event_name)
		@move_action.release(@mouse.position_on_screen)
	end
	
	def cancel(event_name)
		@move_action.cancel
	end
end



end