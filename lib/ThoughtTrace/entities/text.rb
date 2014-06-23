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
		
		
		self.resize!(@components[:physics].shape.height)
	end
	
	def string=(string)
		# Updating the string changes the number of characters,
		# which alters the width
		
		@string = string
		
		
		self.resize!(@components[:physics].shape.height)
	end
	
	
	# interface to set height and width
	# changing one property affects the other
	# This API exists to make constraints etc easier to implement
	# The resize action is still driven by #resize!
	
	def height=(new_height, normalized_anchor=CP::Vec2.new(0,0))
		self.resize!(new_height, normalized_anchor)
	end
	
	def width=(new_width, normalized_anchor=CP::Vec2.new(0,0))
		original_width = @components[:physics].shape.width
		
		ratio = new_width.to_f / original_width.to_f
		
		height = height * ratio
		
		
		self.resize!(height, normalized_anchor)
	end
	
	def height
		@components[:physics].shape.height
	end
	
	def width
		@components[:physics].shape.width
	end
	
	alias :size :height
	alias :size= :height=
	
	
	# TODO: separate line height (hitbox size) and font size (height to render font at)
	
	
	
	# when you set the font, recompute the hitbox
	# when you set the string, recompute the hitbox
	# when you change the size, recompute the hitbox
	
	# update hitbox to match font size
	def resize!(new_height, normalized_anchor=CP::Vec2.new(0,0))
		height = new_height
		width = @font.width(@string, new_height)
		
		
		delta_width, delta_height =
			measure_dimension_delta do
				@components[:physics].shape.resize!(width, height)
			end
		
		
		
		
		@components[:physics].body.p.x -= delta_width * normalized_anchor.x
		@components[:physics].body.p.y -= delta_height * normalized_anchor.y
	end
	
	
	
	
	EMS_PER_CHAR = 0.625
	
	def nearest_character_boundary(point)
		# offset based on measurements between the position of the cursor, and the Text object
			displacement = point - @components[:physics].body.p
			measured_offset = displacement.x
		
		
		
		# target = (0..@string.size).min_by do |i|
		# 	offset = width_of_first(i)
			
			
		# 	puts "#{i.to_s.rjust(4)} :: #{measured_offset} vs #{offset} => #{(offset - measured_offset).abs}"
			
		# 	(offset - measured_offset).abs
		# end
		
		# puts "--> #{target}"
		
		
		
		
		
		# optimizing by finding a nice upper and lower bound
		# rather than making smart jumps between points
		
		# offset based on estimated  math, using average characters per em
			
			px_per_em = @font.width('m', self.height)
			estimated_character_count = measured_offset / (EMS_PER_CHAR * px_per_em)
			
			
			puts "approx char count: #{estimated_character_count}"
			
			estimated_i = estimated_character_count.to_i - 1
			estimated_i = 0 if estimated_i < 0
			
			estimated_offset = width_of_first(estimated_i)
		
		
		
		target = (estimated_i..@string.size).short_circuiting_min_by do |i|
			offset = width_of_first(i)
			
			
			puts "#{i.to_s.rjust(4)} :: #{measured_offset} vs #{offset} => #{(offset - measured_offset).abs}"
			
			(offset - measured_offset).abs
		end
		
		puts "--> #{target}"
		
		
		return target
	end
	
	
	# width of the first n characters
	def width_of_first(n)
		# substring = @text.string[0..i]
		substring = @string.each_char.first(n).join
		# joining is not super efficient, but it's the only way I know of to do this right
		# note that string[0..0] returns the first character, rather than no characters
		
		offset = @font.width(substring, self.height)
		
		return offset
	end
end



end