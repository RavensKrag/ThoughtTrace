module ThoughtTrace


class Rectangle < Entity
	def initialize(width, height)
		# TODO: Update geometry when style is updated, and vice versa. (or else maybe width and height shouldn't be stored in Style)
					body = CP::Body.new(Float::INFINITY, Float::INFINITY)
					shape = CP::Shape::Rect.new body, width, height
		physics = ThoughtTrace::Components::Physics.new self, body, shape
		
		super(physics)
		
		
		
		
		
		# TODO: cascade into default style
		@components[:style].edit(:default) do |s|
			s[:color] = Gosu::Color.argb(0xaa2A3082)
		end
		
		@components[:style].edit(:hover) do |s|
			s[:color] = Gosu::Color.argb(0xaa0000FF)
		end
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		@components[:physics].draw @components[:style][:color], z_index
	end
end



end