module ThoughtTrace
	class Rectangle
		module Actions


# Change dimensions of Rectangle by moving verts around.
# No aspect ratio locking.
class Edit < ThoughtTrace::Rectangle::Actions::Resize
	MARGIN = 20
	MINIMUM_DIMENSION = 10
	
	initialize_with :entity
	
	# called on first tick
	def press(point)
		super(point)
		@core_direction = @direction
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		# if not (@core_direction.x == 0) ^ (@core_direction.y == 0)
		# 	# should grab corners only
		# 	# (not sure what the behavior will be for the center region)
			center = @entity[:physics].center
		# 	@direction = (point - center).normalize
		# end
		
		@a = center
		@b = center + @direction*500
		
		
		
		
		
		
		delta = point - @origin
			
			
			return if delta.zero? # short circuit when there is no movement
			
			
			# only use the component of the displacement in the direction of the edited component
			# ie) the direction of a corner, or one of the edges
			# this is NOT currently the value of the @direction vector
			# that merely shows which edges should be scaled
			# thus, the current implementation scales corners faster
				# (diagonal straight-line distance is shorter than taxi-cab distance)
			
			# get axes
			width = @original_width
			height = @original_height
			
			if @direction.zero?
				
			else
				# ===== Cartesian Scaling =====
				# scale along the axes of the rectangle
				
				# pin down part (edge or vert) of the rectangle, and stretch out the rest
				
				# rescale in the direction specified by @direction
				# displacement towards the center of the shape is negative,
				# displacement towards the outside of the shape is positive
				
				
				if (@direction.x == 0) ^ (@direction.y == 0)
					delta = delta.project(@direction)
				end
				
				width  += delta.x
				height += delta.y
			end
			
			
			
			# limit minimum size (like a clamp, but lower bound only)
			width  = MINIMUM_DIMENSION if width  < MINIMUM_DIMENSION
			height = MINIMUM_DIMENSION if height < MINIMUM_DIMENSION
		
		
		
		@width = width
		@height = height
		@anchor = anchor_point()
		
		
		
		
		
		
		# @anchor = 
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		super()
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		super()
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		super(point)
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		super(point)
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		# TODO: draw margins to get a better idea of how they should be altered as the shape changes.
		# TODO: consider implementing margin rendering using entities and constraints. Then that data could easily be used to drive the modulation of the margins themselves.
		super()
		
		
		
		color = Gosu::Color.argb(0xffFF0000)
		weight = 10
		z = 1000
		
		ThoughtTrace::Drawing.draw_line(
			$window,
			@a,@b,
			color:color, thickness:weight, line_offset:0.5, z_index:z
		)
	end
	
	
	
	
	
	
	private
	
	def anchor_point
		# normalized anchor
		# NOTE: remember that the anchor specifies the amount of counter-steering
		# TODO: allow for more analog anchor specification
		# TODO: consider anchoring based on where the initial point of context was.
		# TODO: consider more complex margin specification. Maybe it should be proportional to size? Not sure in what specify way though.
		x = 
			if @core_direction.x > 0
				# pos
				puts "right"
				0.0
			elsif @core_direction.x < 0
				# neg
				1.0
			else
				# zero
				# center
				0.5
			end
		y = 
			if @core_direction.y > 0
				# pos
				puts "top"
				0.0
			elsif @core_direction.y < 0
				# neg
				1.0
			else
				# zero
				0.5
			end
		
		
		
		return CP::Vec2.new(x,y)
	end
end



end
end
end