require 'set'

module TextSpace
	module InputSystem


class InputManager
	def initialize(space)
		@selection = Set.new
		
		@mouse = Mouse.new
		@actions = ActionSelector.new space, @selection, @mouse
	end
	
	def update
		@actions.hold
	end
	
	
	
	def button_down(id)
		# ----- Global overrides -----
		$window.close if id == Gosu::KbEscape
		
		
		# ----- Main event parsing -----
		case id
			when Gosu::MsLeft
				@actions.press
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