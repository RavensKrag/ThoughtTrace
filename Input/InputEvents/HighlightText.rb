module MouseEvents
	class HighlightText < EventObject
		bind_to :shift_left_click
		pick_object_from :space
		
		def initialize
			super()
		end
		
		def click(selected)
			# get position of character at mouse position
			i = text.closest_character_index(position_in_world)
			@starting_character_offset = text.character_offset i
		end
		
		def drag(selected)
			# extend selection from there
			
			# NOTE: selection should always go from left-most character to right-most
			# if the selection is made from right to left, this will invert things
			# this issue is similar to the one with drawing BBs encountered for box select
			
			i = text.closest_character_index(position_in_world)
			character_offset = text.character_offset i
			
			
			height = text.height # pixels
			
			offset = text.position.clone
			offset.y += height / 2
			
			p0 = @starting_character_offset + offset
			p1 = character_offset + offset
			
			bb = CP::BB.new(p0.x, p0.y-height/2, 
							p1.x, p1.y+height/2)
			bb.reformat # TODO: Rename CP::BB#reformat
			
			bb.draw_in_space @paint_box[:highlight]
		end
		
		# def release(selected)
			# free selection
		# end
	end
end