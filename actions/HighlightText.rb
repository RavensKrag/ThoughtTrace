module TextSpace
	class HighlightText < Action
		bind_to :shift_left_click
		pick_object_from :space
		
		
		def initialize(character_selection)
			super()
			
			@character_selection = character_selection
		end
		
		def click(text)
			# get position of character at mouse position
			i = text.closest_character_index(@mouse.position_in_world)
			@starting_character_offset = text.character_offset i
			
			@start_index = i
		end
		
		def drag(text)
			# extend selection from there
			
			# NOTE: selection should always go from left-most character to right-most
			# if the selection is made from right to left, this will invert things
			# this issue is similar to the one with drawing BBs encountered for box select
			
			i = text.closest_character_index(@mouse.position_in_world)
			
			@end_index = i
			
			# TODO: modify the selection instead of just nuking it every time
			# TODO: make sure that the start index is always lower than the end index
			# TODO: consider moving range boundary test into CharacterSelection
			
			
			@character_selection.delete text
			@character_selection.add text, @start_index..@end_index
		end
		
		# def release(selected)
			# add highlighted text to selection
			
			# there are really two sorts of selections
				# object level
				# character level
				
				# there needs to be some sort of difference, so it's clear what objects
				# events like CutText can operate on
			
			# @character_selection.add(
			# 	selected, @start_index..@end_index
			# )
			
			
			
			# drawing this selection should draw the highlight BB
			# should be able to test against this selection,
			# defining events that fire only when the mouse is over
			# an element of this selection
			# (test against BB)
		# end
	end
end