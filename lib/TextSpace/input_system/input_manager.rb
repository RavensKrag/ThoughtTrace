require 'set'

module TextSpace
	module InputSystem


class InputManager
	def initialize(space, camera)
		@camera = camera
		
		
		@selection = Set.new
		
		@mouse = Mouse.new space
		
		# Don't want to use ActionSelector for camera, because it queries the space
		# queries are not necessary when you know exactly what methods to fire
		# and what objects to fire them on.
		# need another collection that is more useful for that scenario
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