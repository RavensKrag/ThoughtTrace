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
			# copy properties from existing text object
			# make new text object
			# put "overflow" portion of string into new text object
			# remove "overflow" from original text object
			# put new object in space
			# move new object to proper position
			
			old_text = @text_input.text
			
			
			
			font = old_text.font
			height = old_text.height
			
			
			# --- splinter off part of string
			str = old_text.string
			i = @text_input.caret_index
			main, splinter = str.slice!(0..i-1), str
			# first i characters, rest of the string
			# ie) up to and including index i, everything after that
			# (this may not be the correct split index, but the rest of the logic is solid)
			
			@text_input.text.string = main
			
			new_text = ThoughtTrace::Text.new font, splinter
			new_text.height = height
			
			
			
			new_text[:physics].body.p = old_text[:physics].body.p.clone
			new_text[:physics].body.p.y += height
			# TODO: should be minus, eventually. Really would like -y to be down the screen
			
			
			@space.entities.add new_text
			
			
			
			
			@text_input.clear
			@text_input.add new_text, 0
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