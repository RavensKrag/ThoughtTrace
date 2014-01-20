module TextSpace
	class Resize < Action
		def initialize(space)
			super()
			
			@pick_callback = PickCallbacks::Space.new(space)
		end
		
		def pick(point)
			obj = @pick_callback.pick(point)
			if obj
				press obj
				return true
			else
				return false
			end
		end
		
		private
				
		def on_press(obj)
			@selected = obj
			
			@first_position = @selected.physics.body.p
			@resize_basis = @mouse.position_in_world
			
			@screen_position = @mouse.position_on_screen
		end

		def on_hold
			# TODO: Only drag if delta exceeds threshold to prevent accidental drag from click events.  Delta in this case should be measured screen-relative
			screen_delta = @mouse.position_on_screen - @screen_position
			
			if screen_delta.length > 2
				@selected.height = @mouse.position_in_world.y - @selected.physics.body.p.y
			end
		end
	end
end