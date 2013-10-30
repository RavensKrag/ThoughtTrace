module TextSpace
	class MoveCaretAndSelectObject < Action
		bind_to :left_click
		pick_object_from :space
		
		def click(selected)
			@mouse.clear_selection
			
			selected.click
			selected.activate
			
			@mouse.select selected
		end
		
		# def drag(selected)
			
		# end
		
		# def release(selected)
			
		# end
	end
end