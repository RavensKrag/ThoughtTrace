module ThoughtTrace


class Text < Rectangle
	DEFAULT_FONT_SIZE = 30
	
	def initialize(font, string="")
		@font = font
		@string = string
		
		
		
		
		
		
		# NOTE: @string has not yet been initialized
		height = DEFAULT_FONT_SIZE
		width = @font.width(@string, height)
		
		super(width, height)
		
		
		
		
		# TODO: cascade into default style
		@components[:style].edit(:default) do |s|
			s[:color] = Gosu::Color.argb(0xffE64240)
			s[:hitbox_color] = Gosu::Color.argb(0xffFFFFFF)
		end
		
		@components[:style].edit(:hover) do |s|
			s[:color] = Gosu::Color.argb(0xff0000FF)
			s[:hitbox_color] = Gosu::Color.argb(0xffFFFFFF)
		end
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		x,y = @components[:physics].body.p.to_a.collect{|i| i.round }
		
		@components[:physics].draw @components[:style][:hitbox_color], z_index
		
		@font.draw	@string, @components[:physics].shape.height.round,
					x,y, z_index, # position relative to top left corner of text
					@components[:style][:color]
	end
	
	def gc?
		@string == ""
	end
	
	
	
	
	attr_reader :font, :string
	# creating methods to set values manually below
	
	def font=(font)
		# Updating the font changes the properties of glyphs,
		# this will update the width, but not the height,
		# as the height is locked to a certain pixel size
		
		@font = font
		
		
		
		# Adjust the width of the backend shape.
		# The width of this piece of Text will most likely have to change,
		# as a result of differing font faces
		width  = @font.width(@string, self.height)
		
		grab_handle = CP::Vec2.new(1,0)
		point       = CP::Vec2.new(width,0)
		@components[:physics].shape.__resize!(
			grab_handle, :local_space, point:point, lock_aspect:false,
			minimum_dimension:0
		)
	end
	
	def string=(string)
		# Updating the string changes the number of characters,
		# which alters the width
		
		@string = string
		
		
		
		
		# only need to alter the width of the backend shape
		width  = @font.width(@string, self.height)
		
		grab_handle = CP::Vec2.new(1,0)
		point       = CP::Vec2.new(width,0)
		@components[:physics].shape.__resize!(
			grab_handle, :local_space, point:point, lock_aspect:false,
			minimum_dimension:0
		)
	end
	
	
	# interface to set height and width
	# changing one property affects the other
	# This API exists to make constraints etc easier to implement
	
	
	# set the height of the Text to a certain value.
	# this also requires recalculation of how wide the Text is.
	def height=(new_height)
		# encode height
		grab_handle = CP::Vec2.new(0,1)
		point       = CP::Vec2.new(0,new_height)
		@components[:physics].shape.__resize!(
			grab_handle, :local_space, point:point, lock_aspect:false,
			minimum_dimension:0
		)
		
		
		# encode a width based on the height we just set
		width  = @font.width(@string, self.height)
		
		grab_handle = CP::Vec2.new(1,0)
		point       = CP::Vec2.new(width,0)
		@components[:physics].shape.__resize!(
			grab_handle, :local_space, point:point, lock_aspect:false,
			minimum_dimension:0
		)
	end
	
	# Given a target width, set the height of the Text,
	# such that the resultant width will be pretty close to the target width.
	def width=(new_width)
		original_width = @components[:physics].shape.width
		
		ratio = new_width.to_f / original_width.to_f
		
		new_height = self.height * ratio
		
		
		self.height = new_height
	end
	
	# height and width should be thought of as exact pixel measurements,
	# even though the backend data store encodes data in floats
	def height
		@components[:physics].shape.height.round
	end
	
	def width
		@components[:physics].shape.width.round
	end
	
	alias :size :height
	alias :size= :height=
	
	
	# TODO: separate line height (hitbox size) and font size (height to render font at)
	
	
	
	# when you set the font, recompute the hitbox
	# when you set the string, recompute the hitbox
	# when you change the size, recompute the hitbox
	
	
	
	
	
	
	
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
		
		# initial estimation based on average characters per em
			
			px_per_em = @font.width('m', self.height)
			estimated_character_count = measured_offset / (EMS_PER_CHAR * px_per_em)
			
			
			puts "approx char count: #{estimated_character_count}"
			
			estimated_i = estimated_character_count.to_i - 1
			estimated_i = 0 if estimated_i < 0
		
		
		
		target = (estimated_i..@string.size).local_min_by do |i|
			offset = width_of_first(i)
			
			
			puts "#{i.to_s.rjust(4)} :: #{measured_offset} vs #{offset} => #{(offset - measured_offset).abs}"
			
			(offset - measured_offset).abs
		end
		
		puts "--> #{target}"
		
		
		return target
	end
	
	
	# width of the first n characters
	def width_of_first(n)
		if n == 0
			return 0
		else
			# note that string[0..0] returns the first character, rather than no characters
			substring = @string[0..n-1]
			offset = @font.width(substring, self.height)
			
			return offset
		end
		
		
		# joining is not super efficient, but it's a sure way to get correct results
		# substring = @string.each_char.first(n).join
		# offset = @font.width(substring, self.height)
		# 
		# return offset
	end
end



end