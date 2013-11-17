module TextSpace
	class BoxSelect < Action
		# if you don't use a pick query, it can execute any time
		
		# that means this currently executes currently with resize
			# (This was with old bindings. It is not true any more)
			# (But this collision problem may still be valid)
		# fire :in_empty_space
		# fire :over_object # over something, idk what it is, you won't have access to it
		
		# TODO: Make sure BoxSelect only fires over empty space
			# should create a new pick type using SelectionQueries.empty_at?
		# TODO: Make sure to draw selection box
		# TODO: Think about how to render selection box such that grouping, selection, and persistent query areas use the same interface (not necessarily the same backend structures, but that would be cool.)
		
		def initialize(space)
			super()
			
			@space = space
		end
		
		def press
			super(nil)
		end
		
		private
		
		def on_press(obj)
			puts "box"
			@box_top_left = @mouse.position_in_world
			
			@box_selection = Set.new
		end
		
		def on_hold
			bottom_right = @mouse.position_in_world
			
			bb = CP::BB.new(@box_top_left.x, bottom_right.y, 
							bottom_right.x, @box_top_left.y)
			bb.reformat # TODO: Rename CP::BB#reformat
			
			bb.draw_in_space @color[:box_select]
			
			# Perform selection using BB
			new_selection = Set.new
			
			@space.bb_query(bb).each do |obj|
				obj.mouse_over
					
				new_selection.add obj
			end
			
			(@box_selection - new_selection).each do |obj|
				obj.mouse_out
			end
			
			@box_selection = new_selection
		end
		
		def on_release
			@box_selection.each do |obj|
				obj.mouse_out
			end
		end
	end
end