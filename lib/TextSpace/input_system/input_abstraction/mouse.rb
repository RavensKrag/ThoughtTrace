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
		
		if @selected
			# check to see if the entity is the same
			
			
			# If the states are different, then put the new one in
			# If there's currently a state active, make sure to deactivate that one first.
			if @enabled != state
				@enabled.disable if @enabled
				
				
				state.enable
				
				@enabled = state
			end
		else
			# entity is now null, which means state must have changed.
			# reject current state
			
			if @enabled
				@enabled.disable
				@enabled = nil
			end
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
		attr_reader :entity
		
		def initialize(entity)
			@entity = entity
		end
		
		def enable
			puts "on"
		end
		
		def disable
			puts "off"
		end
		
		def ==(other)
			if other.is_a? self.class
				self.entity == other.entity
			else
				super(other)
			end
		end
	end
	private_constant :State
end



end
end