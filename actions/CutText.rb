require 'state_machine'

module TextSpace
	class CutText
		def initialize(space, actions, character_selection)
			super() # set up state machine
			
			@cut = Cut.new(character_selection)
			@move = MoveText.new(space)
			
			@actions = actions
		end
		
		# copy necessary values from mouse
		def add_to(mouse)
			[@cut, @move].each do |action|
				action.add_to mouse
			end
		end
		
		
		
		# def press(point)
		# 	# figure out what object to cut from
		# 	# start the Cut action
			
		# 	# TOOD: consider moving the space query out here, and making the Cut action control purely the cutting functionality
			
		# 	@cut.press(point)
		# end
		
		# def update
		# 	# split text using Cut action if the cursor leaves a certain zone
		# 	# add new text object to space
			
		# 	# start to move the new text object
			
			
			
			
		# 	if dragged_outside_bb?
		# 		# transition to next action
		# 		new_text = @cut.release
		# 		@space << new_text
				
		# 		@move.press(new_text)
				
				
		# 		# state change
		# 		@active_action = :move
		# 	end
			
			
		# 	# update the active action
		# 	action = instance_variable_get(@active_action)
		# 	action.update
		# end
		
		# def release
		# 	# let go of new text object
		# 	@move.release
			
			
		# 	# state change
		# 	@active_action = :cut
		# end
		
		
		
		# all states should have the same interface,
		# that way, no method calls are just dropped.
		# At this time I think it's better to stub than to respond that the method doesn't exist.
		state_machine :state, :initial => :cut do
			state :cut do
				def pick(point)
					# query the space
					
					# TOOD: consider moving the space query out here, and making the Cut action control purely the cutting functionality
					
					@cut.pick(point)
				end
				
				def press(obj)
					# directly accept an object
					
					@cut.press(obj)
				end
				
				def update
					# make sure to always update at least once before transitioning
					@cut.update
					
					start_cut if dragged_outside_bb?
				end
				
				def release
					# stop the cut operation, but don't commit the cut
					@cut.cancel
					
					reset
				end
				
				def cancel
					@cut.cancel
					
					reset
				end
			end
			
			state :move do
				def pick(point)
					
				end
				
				def press(obj)
					
				end
				
				def update
					@move.update
				end
				
				def release
					# let go of new text object
					@move.release
					
					
					reset
				end
				
				def cancel
					@move.cancel
					
					reset
				end
			end
			
			
			event :start_move do
				transition :cut => :move
			end
				after_transition :cut => :move, :do => :move_transition
			
			event :reset do
				transition any => :cut
			end
				after_transition any => :cut, :do => :reset_callback
		end
		
		
		private
		
		def move_transition
			# transition into move action
			new_text = @cut.release
			@space << new_text
			
			@move.press(new_text)
		end
		
		
		
		def reset_callback
			
		end
		
		
		
		
		def dragged_outside_bb?
			# assumes that click callbacks start with the mouse inside of the bounding box
			!@selection.bb.contains_vect?(@mouse.position_in_world)
		end
		
		
		# to perform a cut, you need to what to cut from, and how much to cut away
		class Cut < Action
			def initialize(character_selection)
				# this isn't currently going to work
				# the pick query can't directly feed off the cut selection,
				# because the query is looking for the interface #include?(object)
				# what is defined is CharacterSelection#include?(text, range)
					# well, now range is optional,
					# might work
					# 
					# probably not? because you want to know if the cursor is
					# over an active TextSegment (ie, highlight)
					# and not just over any old piece of text
				
				
				# @pick_callback = PickCallbacks::Selection.new(selection)
				@pick_callback = PickCallbacks::Selection.new(character_selection)
				
				@character_selection = character_selection
			end
			
			def pick(point)
				press @pick_callback.pick(point)
			end
			
			private
			
			def on_press(text_to_cut)
				# get the text
				@original_text = text_to_cut
				
				
				@move_text_basis = @mouse.position_in_world
			end
			
			def on_hold
				# figure out what to cut away
			end
			
			def on_release
				# PERFORM THE ACTUAL CUT
				# take selected text
					# remove from existing text object
					# return new text object containing selected text
				
				
				drag_delta = @mouse.position_in_world - @move_text_basis
				
				
				
				
				
				# deselect original Text object
				# figure out what part of selected string should be cut out
				# remove substring from original string, saving substring
				# wrap substring in new Text object
				# copy style properties from original Text object
					# should probably be using some sort of "format copy" method
				# add new object to space
				
				# clear text selection highlight
				
				
				# set position of new text from 
				# position in text from to where cursor was dragged.
				# (intent is for the text to "pop" out of place)
					# --- original comment ---
					# move the text from it's position in the text flow
					# to where the cursor was dragged
					# (intent is for the text to "pop" out of place)
				
				
				# return new text object, so it can be used in later phases
				
				
				
				
				
				
				# unlink the input buffer from the original text object
				# NOTE:	if the cut occurs while the Text is connected to the input buffer,
				# 		then modifying the string with not have the desired effect,
				# 		as the buffer text is being rendered, and not the stored string
				@original_text.text.release
				@original_text.text.deactivate
				
				
				# TODO: Implement this interface, to allow searching for selected ranges, given a text object
				selected_subsectors = @character_selection[@original_text]
				
				# assuming the mouse would only ever be over one range at a time
				# this assumes non-overlapping ranges, and coalescing text segments
				segment =	selected_subsectors.detect do |text_segment|
								text_segment.bb.contains_vect? @mouse.position_in_world
							end
				
				substring = @original_text.string.slice! segment.range # slice and remove
				
				
				text_object = TextSpace::Text.new(@original_text.text.font)
				text_object.string = substring
				
				copy_style @original_text, text_object
				
				
				@space << text_object
				
				
				
				# clear highlight
				@character_selection.delete @original_text, segment.range
				# TODO: consider making the argument to #delete an array, so it's clearer the values are part of a pair
				
				
				
				# set text position
				
				# move the text from it's position in the text flow
				# to where the cursor was dragged
				# (intent is for the text to "pop" out of place)
				@original_text_position = segment.bb.position		# position in flow
				text_object.position = @original_text_position + drag_delta	# offset by drag
				
				
				
				return text_object
			end
			
			
			
			# TODO: move into Text? somewhere where it makes more sense....
			def copy_style(origin, destination)
				# copy style properties from original Text object
				[:height, :color, :box_color].each do |property|
					destination.send "#{property}=", origin.send(property)
				end
			end
		end
		private_constant :Cut
	end
end
