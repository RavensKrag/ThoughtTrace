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
		
		# estimate to get a good starting position, and then get closer
		
		
		height = @text[:physics].shape.height
		
		
		# offset based on measurements between the position of the cursor, and the Text object
			displacement = point - @text[:physics].body.p
			measured_offset = displacement.x
		
		# offset based on math, using average characters per em
			ems_per_char = 0.625
			px_per_em = @text.font.width('m', height)
			estimated_character_count = measured_offset / (ems_per_char * px_per_em)
			
			
			puts "approx char count: #{estimated_character_count}"
			estimated_i = estimated_character_count.round - 1
			estimated_offset = foo(@text, estimated_i)
		
		
		
		# puts "#{estimated_offset} vs #{measured_offset}"
		
		# foo = 
		# 	if estimated_offset < measured_offset
		# 		estimated_i.upto(@text.string.size)
		# 	else
		# 		estimated_i.downto(0)
		# 	end
			
		# possible = 
		# 	foo.select do |i|
		# 		offset = foo(@text, i)
				
		# 		# (check if new offset is closer to measured distance than original estimation)
		# 		[offset, estimated_offset].min_by{ |x| (x - measured_offset).abs  } == offset
		# 	end
		
		# target = possible.last
		
		
		
		
		
		foo = (0..@text.string.size)
		
		target = foo.min_by	do |i|
			# substring = @text.string[0..i]
			substring = @text.string.each_char.first(i).join
			# joining is not super efficient, but it's the only way I know of to do this right
			# note that string[0..0] returns the first character, rather than no characters
			
			offset = @text.font.width(substring, height)
			
			
			
			puts "#{i.to_s.rjust(4)} :: #{measured_offset} vs #{offset} => #{(offset - measured_offset).abs}"
			
			(offset - measured_offset).abs
		end
		
		
		
		
		puts "--> #{target}"
		@buffer.caret_pos = target
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
	
	def foo(text, i)
		puts i
		height = text[:physics].shape.height
		
		width = 
			if i <= 0
				0
			else
				text.font.width(text.string[0..i], height)
			end
		
		width = text.font.width(text.string[0..i], height)
		return width
	end
end



end