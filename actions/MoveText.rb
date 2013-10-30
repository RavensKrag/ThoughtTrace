module TextSpace
	class MoveText < Action
		bind_to :right_click
		pick_object_from :space
		# pick_object_from :space do |object|
		# 	object
		# end
		
		def click(selected)
			# select @drag_selection
			# establish basis for drag
			@move_text_basis = @mouse.position_in_world
			# store original position of text
			@original_text_position = selected.position
		end
		
		def drag(selected)
			# calculate movement delta
			delta = @mouse.position_in_world - @move_text_basis
			# displace text object by movement delta
			selected.position = @original_text_position + delta
		end
		
		# def release(selected)
			
		# end
	end
end