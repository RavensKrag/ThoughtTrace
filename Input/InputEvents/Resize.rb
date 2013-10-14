module MouseEvents
	class Resize < EventObject
		bind_to :shift_right_click
		pick_object_from :space
		
		def initialize
			super()
		end
		
		def click(selected)
			@first_position = selected.position
			@resize_basis = position_in_world
			
			@screen_position = position_on_screen
		end
		
		def drag(selected)
			# TODO: Only drag if delta exceeds threshold to prevent accidental drag from click events.  Delta in this case should be measured screen-relative
			screen_delta = position_on_screen - @screen_position
			
			if screen_delta.length > 2
				selected.height = position_in_world.y - selected.position.y
			end
		end
	end
end