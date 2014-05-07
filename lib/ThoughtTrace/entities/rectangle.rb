module ThoughtTrace


class Rectangle < Entity
	def initialize(width, height)
		super()
		
		
		
		# TODO: cascade into default style
		style = ThoughtTrace::Components::Style.new "rectangle_style_#{self.object_id}"
		style.edit(:default) do |s|
			s[:width] = width
			s[:height] = height
			s[:color] = Gosu::Color.argb(0xaa2A3082)
		end
		
		style.edit(:hover) do |s|
			s[:width] = width
			s[:height] = height
			s[:color] = Gosu::Color.argb(0xaa0000FF)
		end
		
		add_component style
		
		
		# TODO: Update geometry when style is updated, and vice versa. (or else maybe width and height shouldn't be stored in Style)
				body = CP::Body.new(Float::INFINITY, Float::INFINITY)
				shape = ThoughtTrace::Physics::Rectangle.new body, style[:width], style[:height]
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