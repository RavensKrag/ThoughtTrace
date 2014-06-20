module ThoughtTrace


class TextInput
	def initialize
		@buffer = nil
	end
	
	def update
		# dump buffer into active text object
		@text.string = @buffer.text if @buffer
	end
	
	def draw
		# draw the caret
		if @buffer
			pos = @text[:physics].body.p.clone
			puts "pos: #{pos}"
			
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
			
			
			w,h = [10,height]
			verts = [
				CP::Vec2.new(0,0),
				CP::Vec2.new(w,0),
				CP::Vec2.new(w,h),
				CP::Vec2.new(0,h)
			]
			verts.each{ |v|  v.x -= w/2 }
			verts.each{ |v|  v.x += pos.x }
			verts.each{ |v|  v.y += pos.y }
			
			
			# debug output
			puts verts.collect{ |v|  v.to_s }.join(', ')
			
			
			
			color = Gosu::Color.argb(0xffaaaaaa)
			z = 100
			$window.draw_quad	verts[0].x, verts[0].y, color,
								verts[1].x, verts[1].y, color,
								verts[2].x, verts[2].y, color,
								verts[3].x, verts[3].y, color,
								z
		end
	end
	
	
	def add(text)
		@text = text
		@buffer = Buffer.new $window
		
		# load current string contents into the buffer for editing
		@buffer.text = @text.string
	end
	
	# remove all text objects and close the buffer
	def clear
		if @buffer
			@text = nil
			@buffer.close
			@buffer = nil
		end
	end
end



end