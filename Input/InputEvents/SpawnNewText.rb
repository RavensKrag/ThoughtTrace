module MouseEvents
	class SpawnNewText < EventObject
		bind_to :left_click
		pick_object_from :point do |vector|
			puts "new text"
			obj = TextSpace::Text.new
			obj.position = position_in_world
			
			obj
		end
		
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