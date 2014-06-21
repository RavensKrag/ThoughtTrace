module ThoughtTrace


class TextInput
	def initialize
		@buffer = nil
		
		@caret = Caret.new(4)
		@caret.color = Gosu::Color.argb(0xffaaaaaa)
	end
	
	def update
		if @buffer
			# dump buffer into active text object
			@text.string = @buffer.text 
			
			
			
			# update caret
			
			# TODO: adjust height and position of caret as necessary, but maintain width and general properties of it's geometry
			pos = @text[:physics].body.p.clone
			
			font = @text.font
			string = @text.string
			height = @text[:physics].shape.height
			
			
			i = @buffer.caret_pos
			offset = 
				if i == 0
					0
				else
					substring = string[0..(i-1)]
					font.width(substring, height)
				end
			
			pos.x += offset
			
			@caret.position = pos if @caret.position != pos
			@caret.height = height
			
			@caret.update
		end
	end
	
	def draw
		# draw the caret
		if @buffer
			z = 100
			@caret.draw z
		end
	end
	
	
	# specify the text object to begin editing, and the point clicked (in world space)
	# (point used to figure out initial caret index)
	def add(text, point)
		@text = text
		@buffer = Buffer.new $window
		
		# load current string contents into the buffer for editing
		@buffer.text = @text.string
		
		
		
		# move caret based on where the user clicked
		@buffer.caret_pos = nearest_character_boundary(point)
	end
	
	# remove all text objects and close the buffer
	def clear
		if @buffer
			@text = nil
			@buffer.close
			@buffer = nil
		end
	end
	
	
	private
	
	def nearest_character_boundary(point)
		# offset based on measurements between the position of the cursor, and the Text object
			displacement = point - @text[:physics].body.p
			measured_offset = displacement.x
		
		
		
		# target = (0..@text.string.size).min_by do |i|
		# 	offset = foo(@text, i)
			
			
		# 	puts "#{i.to_s.rjust(4)} :: #{measured_offset} vs #{offset} => #{(offset - measured_offset).abs}"
			
		# 	(offset - measured_offset).abs
		# end
		
		# puts "--> #{target}"
		
		
		
		
		
		# optimizing by finding a nice upper and lower bound
		# rather than making smart jumps between points
		
		# offset based on estimated  math, using average characters per em
			height = @text[:physics].shape.height
			
			ems_per_char = 0.625
			px_per_em = @text.font.width('m', height)
			estimated_character_count = measured_offset / (ems_per_char * px_per_em)
			
			
			puts "approx char count: #{estimated_character_count}"
			estimated_i = estimated_character_count.to_i - 1
			estimated_i = 0 if estimated_i < 0
			estimated_offset = foo(@text, estimated_i)
		
		
		
		target = (estimated_i..@text.string.size).short_circuiting_min_by do |i|
			offset = foo(@text, i)
			
			
			puts "#{i.to_s.rjust(4)} :: #{measured_offset} vs #{offset} => #{(offset - measured_offset).abs}"
			
			(offset - measured_offset).abs
		end
		
		puts "--> #{target}"
	end
	
	
	# width of the first n characters of the given Text object, at it's stored font size
	def foo(text, n)
		height = text[:physics].shape.height
		
		# substring = @text.string[0..i]
		substring = text.string.each_char.first(n).join
		# joining is not super efficient, but it's the only way I know of to do this right
		# note that string[0..0] returns the first character, rather than no characters
		
		offset = text.font.width(substring, height)
		
		return offset
	end
end



end