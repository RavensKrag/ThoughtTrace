module ThoughtTrace
	module Events


# NOTE: Events don't need to deal with Memento objects. That's an additional constraint imposed by Action. button events are more general than that
class PressEnter
	def initialize(space, text_input)
		@space = space
		@text_input = text_input
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
				# if you created a new text object, it would be empty
				
				
				# do nothing
				return
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