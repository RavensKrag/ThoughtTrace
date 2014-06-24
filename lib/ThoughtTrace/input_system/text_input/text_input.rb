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
			update_caret_position()
			
			@caret.height = @text.height
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
	
	
	# specify the text object to begin editing, and where to start the input caret
	def add(text, index)
		@text = text
		@buffer = Buffer.new $window
		
		# load current string contents into the buffer for editing
		@buffer.text = @text.string
		
		
		# Move the caret into position
		# (both backend and frontend)
		self.caret_index = index
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
	
	def caret_index=(i)
		raise "Index can not be negative" if i < 0
		
		@buffer.caret_pos = i
		update_caret_position()
	end
	
	
	
	private
	
	# can't be placed in the Caret class
	# because I don't want to let Caret know about the Text or Buffer objects
	def update_caret_position
		i = @buffer.caret_pos
		
		
		pos = @text[:physics].body.p.clone
		
		font = @text.font
		string = @text.string
		height = @text.height
		
		offset = 
			if i == 0
				0
			else
				substring = string[0..(i-1)]
				font.width(substring, height)
			end
		
		pos.x += offset
		
		@caret.position = pos if @caret.position != pos
	end
end



end