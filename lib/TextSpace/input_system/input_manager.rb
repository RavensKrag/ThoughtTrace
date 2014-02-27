require 'set'

module TextSpace
	module InputSystem


class InputManager
	def initialize(space)
		@selection = Set.new
		
		@mouse = Mouse.new
		@actions = ActionSelector.new space, @selection, @mouse
	end	
	
	
	
	def button_down(id)
		# ----- Global overrides -----
		$window.close if id == Gosu::KbEscape
		
		
		# ----- Main event parsing -----
		
	end
	
	def button_up(id)
		
	end
	
	
	def shutdown
		
	end
end



end
end