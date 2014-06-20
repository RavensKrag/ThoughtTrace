class Text
	def initialize
		@@foo ||= 
	end
	
	
	
end





# all text objects that are being edited in one collection
# one collection has a reference to text buffer
# collection copies text buffer contents into text objects at proper caret positions


buffer = Buffer.new


text_objects = []
text_objects.each do |text|
	index = text.caret_position
	text.string.insert index, buffer.contents
end


# move the carets for particular text objects, rather than moving the input buffer caret
# clear the input buffer whenever a segment of text is dumped into text objects










buffer = Buffer.new

container = Container.new
container.buffer = buffer


container.each  do |text|
	index = text.caret_position
	text.string.insert index, buffer.contents
end


# disconnect the input buffer when no text objects are selected
# connect the input buffer when the first text object is added to an empty container




class Buffer
	def initialize(window)
		@window = window
		
		@input = Gosu::TextInput.new
	end
	
	def open
		@window.text_input = @input
	end
	
	def close
		@window.text_input = nil
	end
end

class Container
	def initialize(window)
		@buffer = Buffer.new(window)
		
		@list = Array.new
	end
	
	
	def update
		@list.each  do |text|
			index = text.caret_position
			text.string.insert index, @buffer.contents
		end
	end
	
	
	
	def add(text)
		@list.add text
		
		@buffer.open if @list.size == 1
	end
	
	def delete(text)
		@list.delete text
		
		@buffer.close if @list.size == 0
	end
	
	# remove all text objects and close the buffer
	def clear
		@list.clear
		@buffer.close
	end
	
	
	
	# move the carets for all text objects
	
	
	# backspace on all text objects
	
	
	# delete on all text objects
end


container = Container.new

container.update


Text.container = container
# attach to a point where the Text objects can access it
# it's basically a global variable at that point, but at least it's namespaced






# issues when moving before the start, or after the end of the current buffer
	# when moving within the boundaries of the current edit,
	# you can use Gosu's text buffer as normal
	# but when moving outside of that, you'd be editing things that are not in the buffer
	# so you need your own sort of buffer
	
	# but when the TextInput is connected, gosu routes input to moving the text caret
	# which is unfortunate,
	# because you can't set the caret programatically,
	# and you can't set the buffer text
	
	
	# oh wait, no you totally can set the buffer text
	# man, this documentation is lacking...
	# you can also set the caret.
	
	
	# huh, guess I misunderstood the documentation

# single object edits aren't a problem,
# but multiple edits are kinda funky











# don't think Gosu's text input will work well with multiple edit mode
# that's not really a core feature right now anyway

# just made a single object input buffer transfer object instead

class Buffer
	def initialize(window)
		@window = window
		
		@input = Gosu::TextInput.new
	end
	
	def open
		@window.text_input = @input
	end
	
	def close
		@window.text_input = nil
	end
	
	# delegate to @input
	[:string, :string=, :caret_pos, :caret_pos=]
	# maybe need to raise some sort of error if the buffer is not open?
end

class Container
	def initialize(window)
		@buffer = Buffer.new(window)
		
		@text = nil
	end
	
	
	def update
		if @text # if there is an object connected to the input buffer
			# dump the contents of the buffer into the active object
			@text.string = @buffer.string
		end
	end
	
	def draw
		# render the input caret,
		# selected characters?
		# things like that
		
		
		# (character selection action will probably show character selection)
		# (probably no need to do that here?)
	end
	
	
	
	
	
	
	def add(text)
		@text = text
		@buffer.open
		
		# load current string contents into the buffer for editing
		@buffer.string = @text.string
	end
	
	# remove all text objects and close the buffer
	def clear
		@text = nil
		@buffer.close
	end
end



container = Container.new(window)

container.update


ThoughtTrace::Text.container = container





# container has to have a lifetime longer than the memento execution
# so that it can hold the buffer and close it at some later time
# because the opening of the buffer is just the beginning of the text input phase

ThoughtTrace::Text.new(window)
	Memento.new(window)
		
	
# consider making the window a global, but without any custom fields accessible
# that would allow for the connection of the input buffer to the window,
# without having to expose window through the entire chain
# which would allow for opening the buffer wherever

# that solves half

# but it doesn't inform where the collection should be stored

ThoughtTrace::Text.currently_editing
ThoughtTrace::Text.active_objects
# something like that?

# somewhere under input manager makes the most sense



# could send text input buffer to all actions instead of the action stash,
# which is pretty much unnecessary at this stage
# NOTE: the 'selection' has not yet been passed to actions, so the action initializer needs rewriting anyway
	# I don't think any child classes change the initializer, so that might actually be super easy




# store window in global variable
	# but do not make any new properties visible
	# (necessary both for text input as well as the initialization of things like Font objects)
# store collection of text objects being actively edited under input manager
	# stored as the "text input"
# pass text input to each Action on init
	# for a total standard args of: space, selection, text input
	# (remove action stash)
# pass variable to Memento through the past/future variables
	# may actually make more sense the future
	
	# if the forward/reverse methods become function calls will blocks
	# then then the variable names can be renamed
	# because they will just be block variables
	# (like how when you call #each you get to name the variables)


class InputManager
	def initialize
		@text_input = TextInput.new
		
		
		action_flow = ThoughtTrace::ActionFlowController.new(@space, @selection, @text_input)
	end
end

class Action
	def initialize(space, selection, text_input, entity)
		@text_input = text_input
	end
	
	
	
	
	Memento.new(@text_input, nil)
	
	
	
	class Memento
		def initialize(past,future)
			@past = past
			@future = future
		end
		
		def forward
			text_input = @past
			
			text_input.add @entity
		end
		
		def reverse
			text_input = @past
			
			text_input.clear
		end
	end
end




class TextInput
	def initialize
		@buffer = nil
	end
	
	def update
		# dump buffer into active text object
		@text.string = @buffer.string if @buffer
	end
	
	def draw
		# draw the caret
		if @buffer
			# @buffer.caret_pos
		end
	end
	
	
	def add(text)
		@text = text
		@buffer = Buffer.new $window
		
		# load current string contents into the buffer for editing
		@buffer.string = @text.string
	end
	
	# remove all text objects and close the buffer
	def clear
		if @buffer
			@text = nil
			@buffer.close
		end
	end
end


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
	
	delegate methods:[:string, :string=, :caret_pos, :caret_pos=], to: @input
	# maybe need to raise some sort of error if the buffer is not open?
end

# open the input buffer by creating an object
# similar to how file IO works in Ruby



# similar to File.new
# can close with #close
# or close at end of block


# needs to interface with a TextInput instance (created via Gosu::Window#text_input)
# or rather, that's where you need to attach the TextInput


# it is possible that you may want to edit multiple Text objects at once

# (lot of things to consider here)



# need to be careful not to open more than one buffer at a time
# as only one TextInput can be bound to the Window at once