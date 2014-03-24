module ThoughtTrace


class Rectangle < Entity
	def initialize(width, height)
		super()
		
		
		
		# TODO: cascade into default style
		style = ThoughtTrace::Components::Style.new
			style[:width] = width
			style[:height] = height
			style[:color] = Gosu::Color.argb(0xaa2A3082)
		
		add_component style
		
		
		# TODO: Update geometry when style is updated, and vice versa. (or else maybe width and height shouldn't be stored in Style)
							body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
							shape = CP::Shape::Rect.new body, style[:width], style[:height]
		add_component	ThoughtTrace::Components::Physics.new self, body, shape
		
		
		add_action ThoughtTrace::Actions::Move.new self
		
		add_action ThoughtTrace::Actions::ResizeRectangle.new self
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		x,y = @components[:physics].body.p.to_a
		
		@components[:physics].draw @components[:style][:color], z_index
	end
end



end