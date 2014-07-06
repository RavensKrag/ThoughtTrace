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
			else
				# split the Text object into multiple parts
				
				# could be somewhere in the middle,
				# could be at the end.
				# (it doesn't actually matter)
				# (the end isn't really a special case)
				
				
				old_text = @text_input.text
				new_text = @clone_factory.make ThoughtTrace::Text
				
				
				
				# --- splinter off part of string
				str = old_text.string
				main, splinter = str.slice!(0..i-1), str
				# first i characters, rest of the string
				# ie) up to and including index i, everything after that
				
				# --- attach strings to corresponding Text objects
				old_text.string = main
				new_text.string = splinter
				
				
				
				# --- add to space
				@space.entities.add new_text
				
				# --- move new Text below the old one (one-line-down effect)
				new_text[:physics].body.p = old_text[:physics].body.p.clone
				new_text[:physics].body.p.y += old_text.height
				
				# --- connect input buffer to the new Text
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