module TextSpace
	module InputSystem


class Mouse
	def initialize
		
	end
	
	def world_position
		return CP::Vec2.new($window.mouse_x, $window.mouse_y).to_world_space
	end
	
	def screen_position
		return CP::Vec2.new($window.mouse_x, $window.mouse_y)
	end
	
	alias :position_in_world :world_position
	alias :position_in_world_coordinates :world_position
	
	alias :position_on_screen :screen_position
	alias :position_in_screen_coordinates :screen_position
end



end
end