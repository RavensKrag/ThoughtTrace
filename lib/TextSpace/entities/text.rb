module TextSpace


class Text < Entity
	attr_accessor :font, :string
	
	def initialize(font, string="")
		super()
		
		@font = font
		@string = string
		
		
		
		
		# TODO: cascade into default style
		style = TextSpace::Components::Style.new
			style[:height] = 30
			style[:color] = Gosu::Color.argb(0xffFFFFFF)
		
		add_component style
		
		
		# NOTE: @string has not yet been initialized
		width = @font.width(@string, @components[:style][:height])
		height = @components[:style][:height]
		
							body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
							shape = CP::Shape::Rect.new body, width, height
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
end



end