module TextSpace
	class TextBox < Action
		# need to be able to set binding at runtime
		# need to be able to load binding from file
			# I think ideally the binding would show up in this file?
			# not sure what the best way to show this data in the end is
			
			# might want to be able to write straight to this file to save bindings?
				# would get weird if you want to have different sets of bindings, no?
				# put the active bind here and store extra bindings elsewhere?
		bind_to :left_click
		pick_object_from :point
		
		def click(selected)
			# generate basis for box
			# spawn caret?
			@text_box_top_left = @mouse.position_in_world
		end
		
		def drag(selected)
			# stretch box extents
			bottom_right = @mouse.position_in_world
			
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