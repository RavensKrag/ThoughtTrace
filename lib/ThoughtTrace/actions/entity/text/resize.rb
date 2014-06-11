module ThoughtTrace
	class Text < Rectangle
		module Actions


class Resize < Rectangle::Actions::Resize
	MARGIN = 50
	MINIMUM_FONT_HEIGHT = 10
	
	# called on first tick
	def setup(point)
		super(point) # sets @origin and @direction
	end
	
	# return two values: past and future used by Memento
	# called each tick
	def update(point)
		# apply one tick of resize change
		# each time this method is called, one d_size / d_t should be applied
		
		# can think of this method as a loop
		# each time the game loop hits this method,
		# it will advance the resizing algorithm by one tick
		
		# this method has circular flow
		# because it will be called every tick
		# as long as the button is held
		
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
			width = @entity[:physics].shape.width
			height = @entity[:physics].shape.height
			
		
				# ===== Scale in one direction only =====
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
					
					
					if @direction.x < 0
						width -= projection.x
					else
						width += projection.x
					end
					
					
					original_width = @entity[:physics].shape.width
					ratio = width.to_f / original_width.to_f
					
					height = height * ratio
				end
			
			
			# limit minimum size (like a clamp, but lower bound only)
			height = MINIMUM_FONT_HEIGHT if height < MINIMUM_FONT_HEIGHT
			
			
			
			
			# must clamp new values first before comparing to old values to get proper deltas
			old_width  = @entity[:physics].shape.width
			old_height = @entity[:physics].shape.height
			
				
				@entity.resize!(height)
			
			
			new_width  = @entity[:physics].shape.width
			new_height = @entity[:physics].shape.height
			
			
			delta_width = old_width - new_width
			delta_height = old_height - new_height
			
			
			
			
			# shape always expands in the positive direction of the adjusted axis
			# thus, if you stretch left or down, you need to shift the center
			# in order to make it feel like the rest of the geometry is firmly planted in place.
			
			# Needs a "center" counter-steering type not present in rectangle resizing
			# because the height and width change together.
			# Center counter-steering maintains the feel that the main edge is moving.
			
			x_offset =	if @direction.x < 0
							# left
							
							delta_width
						elsif @direction.x > 0
							# right
							
							# no movement
							0
						else
							# center
							
							delta_width / 2
						end
			@entity[:physics].body.p.x += x_offset
			
			
			y_offset =	if @direction.y < 0
							# bottom
							
							delta_height
						elsif @direction.y > 0
							# top
							
							# no movement
							0
						else
							# center
							
							delta_height / 2
						end
			@entity[:physics].body.p.y += y_offset
			
			
			
		@origin = point
		
		
		
		
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
			@entity.baz(@future)
		end
		
		# set past state
		def reverse
			@entity.baz(@past)
		end
	end
end



end
end
end