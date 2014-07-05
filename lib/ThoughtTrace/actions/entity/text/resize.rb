module ThoughtTrace
	class Text < Rectangle
		module Actions


class Resize < Rectangle::Actions::Resize
	MARGIN = 50
	MINIMUM_FONT_HEIGHT = 10
	
	# called on first tick
	def setup(point)
		return super(point) # sets @origin and @direction
	end
	
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
			width = @original_width
			height = @original_height
			
		
				# ===== Cartesian Scaling =====
				# scale along the axes of the rectangle
				
				# pin down part (edge or vert) of the rectangle, and stretch out the rest
				
				# rescale in the direction specified by @direction
				# displacement towards the center of the shape is negative,
				# displacement towards the outside of the shape is positive
				
				projection = local_displacement.project(@direction)
				
				# NOTE: projection gets all sorts of screwy when @direction is (0,0)
				
				# switching to using @direction instead
				
				# this leaves the center zone inactive
				# but on Rectangle, the center zone is used for radial (aka uniform) scaling
				# that doesn't make sense for Text
				# so it's acceptable to have an inactive zone instead
				
				
				# Compute new dimensions
				if @direction.y != 0
					# Vertical Scaling
					
					if @direction.y < 0
						height -= projection.y
					else
						height += projection.y
					end
				elsif @direction.x != 0
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
		
		
		
		return height, anchor_point()
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw(point)
		
	end
	
	
	
	# perform the transformation here
	# by encapsulating the transform in this object,
	# it becomes easy to redo / undo actions as necessary
	ParentMemento = self.superclass.const_get 'Memento'
	class Memento < ParentMemento
		# set future state
		def forward
			height, anchor = @future
			@entity.resize!(height, anchor)
		end
		
		# set past state
		def reverse
			width = @initial[0]
			height = @initial[1]
			anchor = @future[1]
			@entity.resize!(height, anchor)
		end
	end
end



end
end
end