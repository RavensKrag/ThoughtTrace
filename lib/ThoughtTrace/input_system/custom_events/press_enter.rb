module ThoughtTrace
	module Events


# NOTE: Events don't need to deal with Memento objects. That's an additional constraint imposed by Action. button events are more general than that
class PressEnter
	def initialize(space, text_input, clone_factory)
		@space = space
		@text_input = text_input
		@clone_factory = clone_factory
	end
	
	def press
		if @text_input.active?
			# Effect similar to inserting a newline in a text editor
			# create new text objects as necessary
			
			# TODO: coordinate system - make sure that -y is down the screen, update position shifts accordingly.
			
			i = @text_input.caret_index
			
			if i == 0
				# at the start of the string
				# creating a new Text would be a little silly
				
				# might as well move the Text though, for a consistent mental model
				old_text = @text_input.text
				
				old_text[:physics].body.p.y += old_text.height
			elsif i == @text_input.text.string.size
				# at the end of the string
				# if you created a new text object by splintering, it would be empty
				
				# Optimize for that empty creation case.
				
				
				
				
				# create a new empty Text object, in the style of the old one,
				# one line down from the old Text.
				# 
				# ThoughtTrace does not strictly align text to lines like a text editor,
				# so this only controls where the line is spawned, not where it will stay.
				# 
				# This is nice, because it allows for fast text input with just a keyboard.
				# No need to jump to the mouse to enter a bunch of lines in quick succession.
				
				
				
				# create new blank Text, in the style of the currently selected Text
				old_text = @text_input.text
				
				@clone_factory.register_prototype old_text
				new_text = @clone_factory.make ThoughtTrace::Text
				
				# add to space
				@space.entities.add new_text
				
				# move new Text below the old one
				new_text[:physics].body.p = old_text[:physics].body.p.clone
				new_text[:physics].body.p.y += old_text.height
				
				
				
				
				# connect input buffer to the new Text
				@text_input.clear
				@text_input.add new_text, 0
			else
				# somewhere in the middle
				# split the Text object into multiple parts
				
				
				# copy properties from existing text object
				# make new text object
				# put "overflow" portion of string into new text object
				# remove "overflow" from original text object
				# put new object in space
				# move new object to proper position
				# put the new object into the input system, instead of the old one
				old_text = @text_input.text
				
				
				
				font = old_text.font
				height = old_text.height
				
				
				# --- splinter off part of string
				str = old_text.string
				main, splinter = str.slice!(0..i-1), str
				# first i characters, rest of the string
				# ie) up to and including index i, everything after that
				
				
				# --- put attributes in the proper places
				old_text.string = main
				
				new_text = ThoughtTrace::Text.new font, splinter
				new_text.height = height
				
				
				# --- position the new object within the space
				new_text[:physics].body.p = old_text[:physics].body.p.clone
				new_text[:physics].body.p.y += height
				
				@space.entities.add new_text
				
				
				# --- reconnect input buffer
				@text_input.clear
				@text_input.add new_text, 0
			end
		end
	end
	
	def hold
		
	end
	
	def release
		
	end
	
	def cancel
		
	end
end



end
end