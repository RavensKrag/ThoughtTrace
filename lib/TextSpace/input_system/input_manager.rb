require 'set'

module TextSpace
	module InputSystem


class InputManager
	def initialize(space, camera)
		@camera = camera
		
		
		@selection = Set.new
		
		@mouse = Mouse.new space
		
		@actions = {
			:left => ActionSelector.new(space, @selection),
			:middle => ActionSelector.new(space, @selection),
			:right => ActionSelector.new(space, @selection)
		}
	end
	
	
	
	
	
	def button_down(id)
		# ----- Global overrides -----
		$window.close if id == Gosu::KbEscape
		
		
		# ----- Main event parsing -----
		point = @mouse.position_in_world
		
		case id
			when Gosu::MsLeft
				@actions[:left].press point
			when Gosu::MsMiddle
				
			when Gosu::MsRight
				
		end
	end
	
	
	
	def update
		@mouse.update
		
		
		
		point = @mouse.position_in_world
		
		@actions[:left].hold point
	end
	
	
	
	def button_up(id)
		case id
			when Gosu::MsLeft
				@actions[:left].release
			when Gosu::MsMiddle
				
			when Gosu::MsRight
				
		end
	end
	
	
	def shutdown
		
	end
end



end
end