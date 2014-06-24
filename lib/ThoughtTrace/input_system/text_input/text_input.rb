module ThoughtTrace


class TextInput
	attr_reader :text
	
	def initialize
		@buffer = nil
		@text = nil
		
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
	def add(text, point=nil)
		@text = text
		@buffer = Buffer.new $window
		
		# load current string contents into the buffer for editing
		@buffer.text = @text.string
		
		
		
		# move caret based on where the user clicked
		if point
			@buffer.caret_pos = @text.nearest_character_boundary(point)
		else
			@buffer.caret_pos = 0
		end
	end
	
	# remove all text objects and close the buffer
	def clear
		if @buffer
			@text = nil
			@buffer.close
			@buffer = nil
		end
	end
	
	
	# Return true if the text input buffer is connected
	def active?
		!@buffer.nil?
	end
	alias :open? :active?
	alias :connected? :active?
	
	
	
	def caret_position
		@caret.position
	end
	
	def caret_index
		@buffer.caret_pos
	end
end



end