module ThoughtTrace
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
		
		
		# check to see if the entity is the same
		
		
		# If the states are different, then put the new one in
		# If there's currently a state active, make sure to deactivate that one first.
		# 
		# but, don't run enable or disable for states that wrap nil
		# (note that you can't just use the "if cond" syntax shortcut to check for non-nil)
		if @enabled != state
			@enabled.disable if @enabled != nil
			
			
			
			state.enable if state != nil
			
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
	
	# States tend to flicker when the mouse is moved rapidly.
	# Seems to be an issue primarily in the vertical direction.
	class State
		attr_reader :entity
		
		def initialize(entity)
			@entity = entity
		end
		
		def enable
			puts "#{@entity} on"
			
			@old_mode = @entity[:style].mode
			
			@entity[:style].mode = :hover
		end
		
		def disable
			puts "#{@entity} off"
			@entity[:style].mode = @old_mode
		end
		
		def ==(other)
			if other.is_a? self.class
				self.entity == other.entity
			else
				self.entity == other
			end
		end
		
		def nil?
			self.entity.nil?
		end
	end
	private_constant :State
end



end
end