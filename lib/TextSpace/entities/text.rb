module TextSpace


class Text < Entity
	attr_accessor :font, :string
	
	def initialize(font)
		super()
		
		# 				body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
		# 				shape = CP::Shape::Poly.new body, new_geometry(), CP::Vec2.new(0,0)
		# add_component	TextSpace::Components::Physics.new self, body, shape
		
		
		@font = font
		
		
		
		@height = 30
		@color = Gosu::Color.argb(0xffFFFFFF)
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		# @components[:physics].body.p.x
		
		
		# @font.draw	@string, @height,
		# 			@components[:physics].body.p.x, @components[:physics].body.p.y, z_index,
		# 			@color
		@font.draw	@string, @height,
					0,0, z_index, # position relative to top left corner of text
					@color
	end
end



end