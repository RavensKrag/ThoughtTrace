module ThoughtTrace


class TextInput
	class Buffer
		# creating this object opens a buffer
		# call #close to close the buffer
		# (it's kinda like File)
		
		def initialize(window)
			@window = window
			
			@input = Gosu::TextInput.new
			
			# open the buffer
			@window.text_input = @input
		end
		
		def close
			@window.text_input = nil
		end
		
		def caret_pos
			@input.caret_pos
		end
		
		def caret_pos=(pos)
			@input.caret_pos = pos
			@input.selection_start = pos
		end
		
		delegate methods:[:text, :text=], to: :@input
		# maybe need to raise some sort of error if the buffer is not open?
	end
	private_constant :Buffer
	# don't want other places opening up input buffers and messing things up
	# this is sort like a singleton, without actually implementing a singleton
	# (because singletons are awkward)
end



end