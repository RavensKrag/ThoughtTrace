module ThoughtTrace


class Circle < Entity
	def initialize(radius)
		super()
		
		
		
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
							shape = CP::Shape::Circle.new body, radius
		add_component	ThoughtTrace::Components::Physics.new self, body, shape
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		x,y = @components[:physics].body.p.to_a
		
		@components[:physics].draw @components[:style][:color], z_index
	end
	
	
	
	def radius
		@components[:physics].shape.radius
	end
	
	
	def resize!(radius)
		@components[:physics].shape.set_radius! radius
	end
end



end