module TextSpace
	module InputSystem


class Mouse
	attr_reader :selected
	
	def initialize(space)
		@space = space
	end
	
	def update
		@selected = entity_under_cursor
		# used for mouseover events as well as mouse picking
		
		
		# apply mouseover effects
		# consider using a structure similar to the action selector
		# (though maybe just a simple stack this time)
		# (simple stack is more complicated, lol)
		
		
		state = State.new @selected
		
		
		if @enabled.nil?
			state.enable
			
			@enabled = state
		# ^^^	no existing state
		# vvv	some state is active
		elsif @enabled == state
			# do nothing
		else
			@enabled.disable
			
			state.enable
			
			@enabled = state
		end
	end
	
	
	def entity_under_cursor
							point = self.position_in_world
							layers = CP::ALL_LAYERS
							group = CP::NO_GROUP
							set = nil
		return @space.point_query_best point, layers, group, set
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
	
	
	private
	
	class State
		def initialize(entity)
			@entity = entity
		end
		
		def enable
			
		end
		
		def disable
			
		end
	end
	private_constant :State
end



end
end