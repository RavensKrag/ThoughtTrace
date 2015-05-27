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
		
		@font.draw	@string, self.height,
					x,y, z_index, # position relative to top left corner of text
					@components[:style][:color]
	end
	
	def gc?
		@string == ""
	end
	
	
	
	
	
	def resize!(grab_handle, coordinate_space=nil, point:nil, delta:nil, minimum_dimension:1)
		# NOTE: Want to always limit the minimum HEIGHT on resize. Don't really care about what the width is. This applies to Text only, not general rectangles.
		
		
		# save
			# should be the same as Rectangle entity
		original_verts    = @components[:physics].shape.verts
		original_position = @components[:physics].body.p.clone
		
		# process
		counter_steer_anchor = ->(grab_handle){
			countersteer_handle = grab_handle * -1
			x = countersteer_handle.to_a
			type, target_indidies = CP::Shape::Rect::VEC_TO_TRANSFORM_DATA[x]
			
			
			local_anchor = 
				case type
					when :edge
						target_indidies
							.collect{  |i|    @components[:physics].shape.vert(i)    }
							.reduce{   |a,b|  CP::Vec2.midpoint(a,b)                 }
					when :vert
						i = target_indidies.first
						@components[:physics].shape.vert(i)
					else
						return # short-circuit when you attempt to use action on center
				end
			
			return local_anchor
		}
		
		
		
		
		# === prep for counter-steering
		local_anchor = counter_steer_anchor[grab_handle]
		return unless local_anchor
		anchor = @components[:physics].body.local2world(local_anchor)
		
		
		# === set width and height
		# resize the hitbox, and use that to figure out what the final height should be
		# (but going to resize and re-position AGAIN before final render, so no one will see this)
		@components[:physics].shape.resize!(
			grab_handle, coordinate_space, point:point, lock_aspect:true,
			minimum_dimension:minimum_dimension, limit_by: :height
		)
		
		height = @components[:physics].shape.height
		
		# It doesn't feel like you're dragging along the diagonal, as with Rectangle resize.
		# It feels like you're just resizing the width, and then the height changes to match
		# (older Text resize code actually did that, and both old and new have the same behavior)
		# But this new code can be written in terms of scaling to a specific point,
		# where as the old one could only be written in terms of deltas.
		
		
		
		# NOTE: it's important to remember that when specifying a width, you can't always get the width you want. The height of the font, the font face, and the number / type of characters in the string constrain what widths are possible.
		
		
		height = height.round # rounding needs to happen somewhere to prevent jitter. this works.
		# In addition to jitter, it is possible for the hitbox to be sized narrower than the text,
		# which is very very odd.
		
		
		# NOTE: need to set height again to apply rounding.
		h = height
		# puts h
		w = @font.width(@string, h)
		# puts w
		
		a = CP::Vec2.new(1,1)
		b = CP::Vec2.new(w,h)
		
		@components[:physics].shape.resize!(
			a, :local_space, point:b, lock_aspect:false
		)
		
		
		
		# === counter-steer
		local_anchor = counter_steer_anchor[grab_handle]
		@components[:physics].right_hand_on_red(local_anchor, anchor)
			# NOTE: what you really want is to save the local anchor in normalized space, so that you can use the exact same anchor twice. but that still requires the computer to calculate what the local anchor is in NEW non-normalized space. So even though that would be more humanistic, it may be worse for performance. (also floating point errors)
			
			
			
		
		
		# return proc to reverse the process	
		undo = Proc.new do
			# same as for Rectangle
			@components[:physics].shape.set_verts!(original_verts, CP::Vec2.new(0,0))
			@components[:physics].body.p = original_position
		end
		
		return undo
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
		@components[:physics].shape.resize!(
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
		@components[:physics].shape.resize!(
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
		@components[:physics].shape.resize!(
			grab_handle, :local_space, point:point, lock_aspect:false,
			minimum_dimension:0
		)
		
		
		# encode a width based on the height we just set
		width  = @font.width(@string, self.height)
		
		grab_handle = CP::Vec2.new(1,0)
		point       = CP::Vec2.new(width,0)
		@components[:physics].shape.resize!(
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