module TextSpace


class Text < Entity
	attr_accessor :font, :string
	
	def initialize(font)
		super()
		
		@font = font
		
		
		# TODO: cascade into default style
		style = TextSpace::Components::Style.new
			style[:height] = 30
			style[:color] = Gosu::Color.argb(0xffFFFFFF)
		
		add_component style
		
		
		
						body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
						shape = CP::Shape::Poly.new body, new_geometry(), CP::Vec2.new(0,0)
		add_component	TextSpace::Components::Physics.new self, body, shape
		
		
		add_action TextSpace::Actions::Move.new
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		x,y = @components[:physics].body.p.to_a
		
		@font.draw	@string, @components[:style][:height],
					x,y, z_index, # position relative to top left corner of text
					@components[:style][:color]
	end
	
	
	private
	
	def new_geometry
		l = 0
		b = 0
		r = @font.width(@string, @components[:style][:height])
		t = @components[:style][:height]
		
		# cw winding
		verts = [
			CP::Vec2.new(l, t),
			CP::Vec2.new(r, t),
			CP::Vec2.new(r, b),
			CP::Vec2.new(l, b)
		]
		
		raise "Problem with specified verts." unless CP::Shape::Poly.valid? verts
		
		return verts
	end
end



end