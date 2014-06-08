module InputSystem


# converts zero-arg press-hold-release structure into one-arg (point - position of mouse)
# 
# mouse is initialized on a different level,
# so that one mouse can be shared among various input subsystems
class MouseActionController
	def initialize(mouse, action_flow)
		@mouse = mouse
		@action_flow = action_flow
	end
	
	def press
		@action_flow.press(@mouse.position_in_space)
	end
	
	def hold
		@action_flow.hold(@mouse.position_in_space)
	end
	
	def release
		@action_flow.release(@mouse.position_in_space)
	end
	
	def cancel
		@action_flow.cancel
	end
end



end