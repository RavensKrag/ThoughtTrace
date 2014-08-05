module ThoughtTrace


class Rectangle < Entity
	def initialize(width, height)
		super()
		
		# TODO: depreciate width and height being stored in style
		# (maybe not? it would be nice allow element to sync dimensions via style)
		# (maybe that should be the work of some Constraint though?)
		
		
		# TODO: cascade into default style
		style = ThoughtTrace::Components::Style.new
		style.edit(:default) do |s|
			s[:color] = Gosu::Color.argb(0xaa2A3082)
		end
		
		style.edit(:hover) do |s|
			s[:color] = Gosu::Color.argb(0xaa0000FF)
		end
		
		add_component style
		
		
		# TODO: Update geometry when style is updated, and vice versa. (or else maybe width and height shouldn't be stored in Style)
							body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
							shape = CP::Shape::Rect.new body, width, height
		add_component	ThoughtTrace::Components::Physics.new self, body, shape
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		x,y = @components[:physics].body.p.to_a
		
		@components[:physics].draw @components[:style][:color], z_index
	end
	
	
	
	# change dimensions, and don't forget to counter-steer
	def resize!(width, height, normalized_anchor)
		delta_width, delta_height =
			measure_dimension_delta do
				@components[:physics].shape.resize!(width, height)
			end
		
		
		# essentially, the anchor controls the amount of counter-steering
			# values should normalized, ie within the following range
			# x = (0..1)
			# y = (0..1)
			# 
			# 0.0 on the x axis = left edge of the shape is anchored
			# 1.0 on the x axis = right edge of the shape is anchored
			# 0.5 on the x axis = center of the horizontal axis is anchored 
			# 
			# (similarly for the y axis (low end 0.0, high end 1.0, up is high))
			# (NOTE: bottom left is (0,0) in local space for Rect shapes)
		
		@components[:physics].body.p.x -= delta_width * normalized_anchor.x
		@components[:physics].body.p.y -= delta_height * normalized_anchor.y
		
		
		
		# consider anchors in the context of undo/redo
		# the same anchor should allow for forwards/backwards application of the transform
		# thus, anchors should always be normalized
		# other wise, you need a forwards anchor conversion
		# and a backwards anchor conversion
		# and that could get really messy, really fast
	end
	
	
	
	private
	
	# deltas should be positive when expanding, and negative when contracting
	def measure_dimension_delta
		old_width  = @components[:physics].shape.width
		old_height = @components[:physics].shape.height
		
		yield
		
		new_width  = @components[:physics].shape.width
		new_height = @components[:physics].shape.height
		
		delta_width = new_width - old_width
		delta_height = new_height - old_height
		
		return delta_width, delta_height
	end
end



end