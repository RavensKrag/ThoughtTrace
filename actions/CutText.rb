require 'state_machine'

module TextSpace
	class CutText
		def initialize(space, actions, character_selection)
			super() # set up state machine
			
			@cut = Cut.new(character_selection)
			@move = MoveText.new(space)
			
			@space = space
			@actions = actions
		end
		
		# copy necessary values from mouse
		def add_to(mouse)
			[@cut, @move].each do |action|
				action.add_to mouse
			end
		end
		
		
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
					start_move if @cut.dragged_outside_bb?
					
					@actions[TextSpace::MoveText].cancel if @cut.holding?
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
		
		
		
		
		# to perform a cut, you need to what to cut from, and how much to cut away
		class Cut < Action
			def initialize(character_selection)
				super()
				@character_selection = character_selection
				
				
				
				
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
				
				# Restrict picks to TextSegment objects within the character selection collection
				@pick_callback = PickCallbacks::Selection.new(character_selection)
			end
			
			# NOTE: This creates hard coupling with the mouse. This prevents automation of cuts.
			def dragged_outside_bb?
				if holding?
					return !@selected_segment.bb.contains_vect?(@mouse.position_in_world)
				else
					return false
				end
				
				
				# # assumes that click callbacks start with the mouse inside of the bounding box
				# !@original_text.bb.contains_vect?(@mouse.position_in_world)
			end
			
			
			
			def pick(point)
				obj = @pick_callback.pick(point)
				if obj
					press obj
					return true
				else
					return false
				end
			end
			
			private
			
			def on_press(text_segment)
				# get the text
				@selected_segment = text_segment
				
				
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
				# clear text selection highlight
				# extract substring from original string (use TextSegment range)
				
				# wrap substring in new Text object
					# copy style properties from original Text object
				
				# move the text from it's position in the text flow
				# to where the cursor was dragged
				# (intent is for the text to "pop" out of place)
				
				
				# return new text object
				
				
				
				
				original_text = @selected_segment.text
				
				
				# unlink the input buffer from the original text object
				# NOTE:	if the cut occurs while the Text is connected to the input buffer,
				# 		then modifying the string with not have the desired effect,
				# 		as the buffer text is being rendered, and not the stored string.
				# 
				# 		Advancements to the Text API don't really help,
				# 		because the buffer will override the stored text on deactivation,
				# 		so the the text still needs to be deactivated here to prevent overwrite.
				original_text.release
				original_text.deactivate
				
				
				
				
				# clear highlight
				@character_selection.delete original_text, @selected_segment.range
				# TODO: consider making the argument to #delete an array, so it's clearer the values are part of a pair
				
				# extract selected region
				substring = original_text.string.slice! @selected_segment.range # slice and remove
				
				
				
				text_object = TextSpace::Text.new(original_text.font)
				text_object.copy_style_from original_text
				
				text_object.string = substring
				
				
				
				# move the text from it's position in the text flow
				# to where the cursor was dragged
				# (intent is for the text to "pop" out of place)
				text_object.position = @selected_segment.bb.position + drag_delta
				
				
				
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
