module ThoughtTrace
	class TextInput
		module Actions


class NewLine < ThoughtTrace::Actions::OneShotAction
	initialize_with :entity, :space
	
	# called on first tick
	def setup(point)
		# NOTE: where should this condition go?
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
				# (As expected, splinter will an empty string if the caret is at the end)
				
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
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@space.entities.delete @circle
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		
	end
end


	
end
end
end
