module MouseEvents
	class CutText < EventObject
		bind_to :right_click
		pick_object_from :selection
			pick_selection_domain :cut_selection
		
		attr_reader :cut_selection
		
		def initialize(character_selection)
			super()
			
			# this isn't currently going to work,
			# because the pick query assumes it can test #include?(object)
			# where object is some sort of object in the space (ex, Text)
			# what is defined is CharacterSelection#include?(text, range)
				# well, now range is optional,
				# might work
				# 
				# probably not? because you want to know if the cursor is
				# over an active TextSegment (ie, highlight)
				# and not just over any old piece of text
			# @cut_selection = selection
			@cut_selection = [] # TODO: Replace with actual selection domain
		end
		
		def click(selected)
			# pick
			puts "start cut"
			
			
			# from MoveText
			# select @drag_selection
			# establish basis for drag
			@move_text_basis = @mouse.position_in_world
			# store original position of text
			@original_text_position = selected.position
		end
		
		def drag(selected)
			# move to new location
			
			
			# from MoveText
			# calculate movement delta
			delta = @mouse.position_in_world - @move_text_basis
			# displace text object by movement delta
			selected.position = @original_text_position + delta
		end
		
		def release(selected)
			# select new text object formed from cut
			
			
			# from MoveCaretAndSelectObject
			@mouse.clear_selection
			
			selected.click
			selected.activate
			
			@mouse.select selected
		end
	end
end