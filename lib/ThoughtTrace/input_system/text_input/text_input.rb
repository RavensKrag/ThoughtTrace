module ThoughtTrace


class TextInput
	attr_reader :text
	
	def initialize
		@buffer = nil
		@text = nil
		
		@caret = Caret.new(4)
		
		# NOTE: caret already sets it's own style data on init.
		@caret[:style].edit(:default) do |s|
			s[:color] = Gosu::Color.argb(0xffaaaaaa)
		end
		
		@cached_i = nil
	end
	
	def update
		if @buffer
			# dump buffer into active text object
			@text.string = @buffer.text 
			
			
			# update caret
			i = @buffer.caret_pos
			self.caret_index = i
			
			@caret.height = @text.height
			@caret.update
		end
	end
	
	def draw(space)
		# draw the caret
		if @buffer
			z = space.entities.index_for(@text)
			@caret.draw z + space.entities.offsets[:text_caret]
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
		
		return if @cached_i == i
		@cached_i = i
		
		
		# most of this stuff can't be placed in the Caret class
		# because I don't want to let Caret know about the Text or Buffer objects
		
		@buffer.caret_pos = i
		
		
		pos = @text[:physics].body.p.clone
		
		offset = 
			if i == 0
				0
			else
				puts "substrings"
				substring = @text.string[0..(i-1)]
				@text.font.width(substring, @text.height)
			end
		
		pos.x += offset
		
		@caret.position = pos
	end
end



end