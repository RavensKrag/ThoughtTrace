module ThoughtTrace
	class Text < Rectangle
		module Actions


class Resize < Rectangle::Actions::Resize
	MARGIN = 50
	MINIMUM_FONT_HEIGHT = 10
	
	# called on first tick
	def setup(point)
		super(point) # sets @origin and @direction
		
		# Currently using the same @original as Rectangle,
		# because the original width is also needed for interactive resize
		# even though it's not necessary as an argument to Text#resize!
		# @original =
	end
	
	# return two values: past and future used by Memento
	# called each tick
	def update(point)
		local_origin = @entity[:physics].body.world2local @origin
		local_point = @entity[:physics].body.world2local point
		local_displacement = local_point - local_origin
			
			
			return if local_displacement.zero? # short circuit when there is no movement
			
			
			# only use the component of the displacement in the direction of the edited component
			# ie) the direction of a corner, or one of the edges
			# this is NOT currently the value of the @direction vector
			# that merely shows which edges should be scaled
			# thus, the current implementation scales corners faster
				# (diagonal straight-line distance is shorter than taxi-cab distance)
			
			# get axes
			
			
			# for text, you always want to end up computing the height,
			# as opposed to the standard rectangle, where you need both width and height
			width, height = @original
			
		
				# ===== Cartesian Scaling =====
				# scale along the axes of the rectangle
				
				# pin down part (edge or vert) of the rectangle, and stretch out the rest
				
				# rescale in the direction specified by @direction
				# displacement towards the center of the shape is negative,
				# displacement towards the outside of the shape is positive
				
				projection = local_displacement.project(@direction)
				
				
				# Compute new dimensions
				if projection.y != 0
					# Vertical Scaling
					
					if @direction.y < 0
						height -= projection.y
					else
						height += projection.y
					end
				elsif projection.x != 0
					# Horizontal Scaling
					
					# simple ratio solution courtesy of this link
					# http://tech.pro/tutorial/691/csharp-tutorial-font-scaling
					
					new_width = width
					original_width = width
					
					if @direction.x < 0
						new_width -= projection.x
					else
						new_width += projection.x
					end
					
					
					ratio = new_width.to_f / original_width.to_f
					
					height = height * ratio
				end
			
			
			# limit minimum size (like a clamp, but lower bound only)
			height = MINIMUM_FONT_HEIGHT if height < MINIMUM_FONT_HEIGHT
		
		
		
		current = [height, anchor_point()]
		
		return @original, current
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw(point)
		
	end
	
	
	
	# perform the transformation here
	# by encapsulating the transform in this object,
	# it becomes easy to redo / undo actions as necessary
	# (Consider better name. Current class name derives from a design pattern.)
	# (this class also has ideas from the command pattern, though)
	# TODO: consider that writing new versions of Memento may be unnecessary if the Memento always passes the @future / @past value(s) to #forward / #reverse. That's not currently what's happening necessarily, but that might be a good direction to go in.
	ParentMemento = self.superclass.const_get 'Memento'
	class Memento < ParentMemento
		# set future state
		def forward
			height, anchor = @future
			@entity.resize!(height, anchor)
		end
		
		# set past state
		def reverse
			width = @past[0]
			height = @past[1]
			anchor = @future[1]
			@entity.resize!(height, anchor)
		end
	end
end



end
end
end