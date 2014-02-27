module TextSpace


class Text < Entity
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
		
		
		# if you can specify the actions with a 'factory' instead of an instance, you can put real actions onto the action stack, instead of some weird wrapper thing
			# may not need a wrapper
			# still good idea though, because it means that the state can be easily wrapped up in that one instance. No garbage can carry over.
		add_action TextSpace::Actions::Move.new self
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		x,y = @components[:physics].body.p.to_a
		
		@components[:physics].draw Gosu::Color.new(0xaaFF0000), z_index
		
		@font.draw	@string, @components[:style][:height],
					x,y, z_index, # position relative to top left corner of text
					@components[:style][:color]
	end
	
	
	
	
	attr_reader :font, :string
	# creating methods to set values manually below
	
	def font=(font)
		# Updating the font changes the properties of glyphs,
		# this will update the width, but not the height,
		# as the height is locked to a certain pixel size
		
		@font = font
		
		
		width = @font.width(@string, @components[:style][:height])
		height = @components[:style][:height]
		
		
		# @components[:physics].shape.resize! width, height
		@components[:physics].shape.width = width
	end
	
	def string=(string)
		# Updating the string changes the number of characters,
		# which alters the width
		
		@string = string
		
		
		width = @font.width(@string, @components[:style][:height])
		height = @components[:style][:height]
		
		
		# @components[:physics].shape.resize! width, height
		@components[:physics].shape.width = width
	end
	
	# when you set the font, recompute the hitbox
	# when you set the string, recompute the hitbox
	# when you change the size, recompute the hitbox
end



end