module ThoughtTrace


class Text < Rectangle
	DEFAULT_FONT_SIZE = 30
	
	def initialize(font, string="")
		# super()
		
		@font = font
		@string = string
		
		
		
		
		# # TODO: cascade into default style
		# style = ThoughtTrace::Components::Style.new "text_style_#{self.object_id}"
		# style.edit(:default) do |s|
		# 	s[:height] = 30 # <-- depreciated
		# 	s[:color] = Gosu::Color.argb(0xffFFFFFF)
		# end
		
		# style.edit(:hover) do |s|
		# 	s[:height] = 30 # <-- depreciated
		# 	s[:color] = Gosu::Color.argb(0xff0000FF)
		# end
		
		# add_component style
		
		
		# # NOTE: @string has not yet been initialized
		height = DEFAULT_FONT_SIZE
		width = @font.width(@string, height)
		
		# 					body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
		# 					shape = CP::Shape::Rect.new body, width, height
		# add_component	ThoughtTrace::Components::Physics.new self, body, shape
		
		
		
		
		super(width, height)
		
		
		@components[:style].edit(:default) do |s|
			s[:height] = 30 # <-- depreciated
			s[:color] = Gosu::Color.argb(0xffFFFFFF)
		end
		
		@components[:style].edit(:hover) do |s|
			s[:height] = 30 # <-- depreciated
			s[:color] = Gosu::Color.argb(0xff0000FF)
		end
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		x,y = @components[:physics].body.p.to_a
		
		@components[:physics].draw Gosu::Color.new(0xaaFF0000), z_index
		
		@font.draw	@string, @components[:physics].shape.height,
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
		
		
		width = @font.width(@string, @components[:physics].shape.height)
		height = @components[:physics].shape.height
		
		
		# @components[:physics].shape.resize! width, height
		@components[:physics].shape.width = width
	end
	
	def string=(string)
		# Updating the string changes the number of characters,
		# which alters the width
		
		@string = string
		
		
		width = @font.width(@string, @components[:physics].shape.height)
		height = @components[:physics].shape.height
		
		
		# @components[:physics].shape.resize! width, height
		@components[:physics].shape.width = width
	end
	
	# when you set the font, recompute the hitbox
	# when you set the string, recompute the hitbox
	# when you change the size, recompute the hitbox
	
	# update hitbox to match font size
	def resize!(new_height)
		height = new_height
		width = @font.width(@string, new_height)
		
		
		@components[:physics].shape.resize! width, height
	end
end



end