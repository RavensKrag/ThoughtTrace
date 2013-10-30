module TextSpace
	class SpawnNewText < Action
		bind_to :left_click
		pick_object_from :point do |vector|
			puts "new text"
			obj = TextSpace::Text.new
			obj.position = @mouse.position_in_world
			
			obj
		end
		
		
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