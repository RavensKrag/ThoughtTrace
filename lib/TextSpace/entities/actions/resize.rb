module TextSpace
	module Actions


class Resize < Action
	interface_name :resize
	components :physics
	
	
	def setup(stash, point)
		super(stash, point)
		
		# mark the initial point for reference
		@origin = point
		
		# test in which region of the shape the point lies
		# ASSUMPTION: point is already known to lie within the shape
		case @components[:physics].shape.foo point
			when :right
				
			when :left
				
			when :top
				
			when :bottom
				
		end
	end
	
	def update(point)
		super(point)
		
		# apply one tick of resize change
		# each time this method is called, one d_size / d_t should be applied
		
		# can think of this method as a loop
		# each time the game loop hits this method,
		# it will advance the resizing algorithm by one tick
		
		# this method has circular flow
		# because it will be called every tick
		# as long as the button is held
		
		displacement = @origin - point
		
			angle = displacement.to_angle
			magnitude = displacement.length
			
			@components[:physics].resize angle, magnitude
			# need more information than that
			# for things like rectangles,
			# it's important where the original click occurred,
			# so that you can tell one edge drag from another.
			
		@origin = point
	end
	
	def cleanup
		super()
		
		
	end
end



end
end