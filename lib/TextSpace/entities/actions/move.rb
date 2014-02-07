class Move < Action
	interface_name :move
	components :physics
	
	
	def on_press(point)
		# @components[:physics]
		# @actions[:move]
	end
	
	def on_hold(point)
		
	end
	
	def on_release(point)
		
	end
end