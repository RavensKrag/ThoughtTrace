module MouseEvents
	class MoveText < EventObject
		bind_to :right_click
		pick_object_from :space
		# pick_object_from :space do |object|
		# 	object
		# end
		
		def initialize
			super()
		end
		
		def click(selected)
			# select @drag_selection
			# establish basis for drag
			@move_text_basis = position_in_world
			# store original position of text
			@original_text_position = selected.position
		end
		
		def drag(selected)
			# calculate movement delta
			delta = position_in_world - @move_text_basis
			# displace text object by movement delta
			selected.position = @original_text_position + delta
		end
		
		# def release(selected)
			
		# end
	end
end