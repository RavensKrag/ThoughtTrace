module TextSpace
	module Actions


class Move < Action
	interface_name :move
	components :physics
	
	
	def on_press(point)
		# mark the initial point for reference
		@origin = point
		@start = @components[:physics].body.p
	end
	
	def on_hold(point)
		# move relative to the initial point
		displacement = @origin - point
		
		@components[:physics].body.p = @start + displacement
	end
	
	def on_release(point)
		
	end
end



end
end