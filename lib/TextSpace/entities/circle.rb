module TextSpace


class Circle < Entity
	def initialize(radius)
		super()
		
		
		
		# TODO: cascade into default style
		style = TextSpace::Components::Style.new
			style[:radius] = radius
			style[:color] = Gosu::Color.argb(0xaa2A3082)
		
		add_component style
		
		
		# TODO: Update geometry when style is updated, and vice versa. (or else maybe width and height shouldn't be stored in Style)
							body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
							shape = CP::Shape::Circle.new body, style[:radius]
		add_component	TextSpace::Components::Physics.new self, body, shape
		
		
		add_action TextSpace::Actions::Move.new self
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		x,y = @components[:physics].body.p.to_a
		
		@components[:physics].draw @components[:style][:color], z_index
	end
end



end