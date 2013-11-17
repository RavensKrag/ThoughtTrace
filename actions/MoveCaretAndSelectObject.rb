module TextSpace
	class MoveCaretAndSelectObject < Action
		def initialize(space)
			super()
			
			@pick_callback = PickCallbacks::Space.new(space)
		end
		
		def pick(point)
			press @pick_callback.pick(point)
		end
		
		private
		
		def on_press(selected)
			@mouse.clear_selection
			
			selected.click
			selected.activate
			
			@mouse.select selected
		end

		# def on_hold
			
		# end

		# def on_release
			
		# end
	end
end