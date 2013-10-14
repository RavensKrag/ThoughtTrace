module MouseEvents
	class MoveCaretAndSelectObject < EventObject
		bind_to :left_click
		pick_object_from :space
		
		def initialize
			super()
		end
		
		def click(selected)
			clear_selection
			
			selected.click
			selected.activate
			
			select selected
		end
		
		# def drag(selected)
			
		# end
		
		# def release(selected)
			
		# end
	end
end