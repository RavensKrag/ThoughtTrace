module InputSystem


class Mouse
	def initialize(window, camera)
		@window = window
		@camera = camera
		
		@buttons = {
			Gosu::MsLeft   => :left,
			Gosu::MsRight  => :right,
			Gosu::MsMiddle => :middle
		}
		
		@callbacks = {
			:click => Hash.new,
			:release => Hash.new
		}
	end
	
	# hook into input manager's update loop
	# to process mouseover effects and such
	def update
		
	end
	
	def button_down(id)
		mb = @buttons[id]
		if mb
			callback = @callbacks[:click][mb]
			callback.call if callback
		end
	end
	
	def button_up(id)
		mb = @buttons[id]
		if mb
			callback = @callbacks[:release][mb]
			callback.call if callback
		end
	end
	
	
	def on_click(button, &block)
		@callbacks[:click][button] = block
	end
	
	def on_release(button, &block)
		@callbacks[:release][button] = block
	end
	
	
	
	
	def world_position
		return @camera.screen2world screen_position
	end
	
	def screen_position
		return CP::Vec2.new(@window.mouse_x, @window.mouse_y)
	end
	
	alias :position_in_world :world_position
	alias :position_in_world_coordinates :world_position
	
	alias :position_in_space :world_position
	
	alias :position_on_screen :screen_position
	alias :position_in_screen_coordinates :screen_position
end



end
