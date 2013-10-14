module MouseEvents
	class TextBox < EventObject
		bind_to :left_click
		pick_object_from :space
		
		def click(selected)
			# generate basis for box
			# spawn caret?
			@text_box_top_left = position_in_world
		end
		
		def drag(selected)
			# stretch box extents
			bottom_right = position_in_world
			
			bb = CP::BB.new(@text_box_top_left.x, bottom_right.y, 
							bottom_right.x, @text_box_top_left.y)
			bb.reformat # TODO: Rename CP::BB#reformat
			
			bb.draw_in_space @color[:box_select]
		end
		
		def release(selected)
			# cement box constraints
			# enable box for editing
		end
	end
end