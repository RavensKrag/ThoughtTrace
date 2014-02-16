module TextSpace


class Text < Entity
	attr_accessor :font, :string
	
	def initialize(font)
		super()
		self.add_component TextSpace::Components::Physics
		
		
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