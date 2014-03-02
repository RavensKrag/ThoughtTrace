require 'set'

module TextSpace
	module InputSystem


class InputManager
	def initialize(space)
		@selection = Set.new
		
		@mouse = Mouse.new space
		@actions = ActionSelector.new space, @selection
	end
	
	def update
		@actions.hold @mouse.position_in_world
	end
	
	
	
	def button_down(id)
		# ----- Global overrides -----
		$window.close if id == Gosu::KbEscape
		
		
		# ----- Main event parsing -----
		case id
			when Gosu::MsLeft
				@actions.press @mouse.position_in_world
		end
	end
	
	def button_up(id)
		case id
			when Gosu::MsLeft
				@actions.release
		end
	end
	
	
	def shutdown
		
	end
end



end
end