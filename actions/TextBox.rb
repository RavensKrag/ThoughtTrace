module TextSpace
	class TextBox < Action
		# need to be able to set binding at runtime
		# need to be able to load binding from file
			# I think ideally the binding would show up in this file?
			# not sure what the best way to show this data in the end is
			
			# might want to be able to write straight to this file to save bindings?
				# would get weird if you want to have different sets of bindings, no?
		# 		# put the active bind here and store extra bindings elsewhere?
		
		
		# pick_object_from :point
		# might want to just pick the point, not generate some object there?
		# but then again, the text box should probably be resizeable, so...
		
		# def initialize(space)
		# 	@pick_callback = PickCallback::Point.new(space, TextSpace::Text)
		# end
		
		# def press(point)
		# 	super @pick_callback.pick(point)
		# end
		
		private
		
		def on_press(obj)
			# generate basis for box
			# spawn caret?
			@text_box_top_left = @mouse.position_in_world
		end
		
		def on_hold
			# stretch box extents
			bottom_right = @mouse.position_in_world
			
			bb = CP::BB.new(@text_box_top_left.x, bottom_right.y, 
							bottom_right.x, @text_box_top_left.y)
			bb.reformat # TODO: Rename CP::BB#reformat
			
			bb.draw_in_space @color[:box_select]
		end

		def on_release
			# cement box constraints
			# enable box for editing
		end
	end
end