module TextSpace
	module Actions


class Move < Action
	interface_name :move
	components :physics
	
	
	# Executed before adding to queue
	def setup(stash, point)
		super(stash, point)
		
		# mark the initial point for reference
		@origin = point
		@start = @components[:physics].body.p.clone
	end
	
	def update(point)
		super(point)
		
		# move relative to the initial point
		displacement = point - @origin
		
		@components[:physics].body.p = @start + displacement
	end
	
	# Executed after removed from queue
	def cleanup
		super()
		
		
	end
end



end
end