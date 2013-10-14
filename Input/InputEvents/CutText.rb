module MouseEvents
	class CutText < EventObject
		bind_to :right_click
		pick_object_from :selection
		
		def initialize
			super()
		end
		
		def click(selected)
			# pick
		end
		
		def drag(selected)
			# move to new location
		end
		
		def release(selected)
			# deselect new text object formed from cut
		end
	end
end