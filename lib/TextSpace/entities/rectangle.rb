module TextSpace


class Rectangle < Entity
	def initialize(width, height)
		super()
		
		
		
		# TODO: cascade into default style
		style = TextSpace::Components::Style.new
			style[:width] = width
			style[:height] = height
			style[:color] = Gosu::Color.argb(0xffFFFFFF)
		
		add_component style
		
		
		# TODO: Update geometry when style is updated, and vice versa. (or else maybe width and height shouldn't be stored in Style)
							body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
							shape = CP::Shape::Rect.new body, style[:width], style[:height]
		add_component	TextSpace::Components::Physics.new self, body, shape
		
		
		add_action TextSpace::Actions::Move.new self
		
		add_action TextSpace::Actions::ResizeRectangle.new self
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		x,y = @components[:physics].body.p.to_a
		
		@components[:physics].draw Gosu::Color.new(0xaaFF0000), z_index
	end
end



end