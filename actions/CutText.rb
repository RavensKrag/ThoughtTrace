require 'state_machine'

module TextSpace
	class CutText < Action
		bind_to :right_click
		pick_object_from :selection
			pick_selection_domain :cut_selection
		
		attr_reader :cut_selection
		
		def initialize(character_selection)
			super()
			
			# this isn't currently going to work,
			# because the pick query assumes it can test #include?(object)
			# where object is some sort of object in the space (ex, Text)
			# what is defined is CharacterSelection#include?(text, range)
				# well, now range is optional,
				# might work
				# 
				# probably not? because you want to know if the cursor is
				# over an active TextSegment (ie, highlight)
				# and not just over any old piece of text
			@cut_selection = character_selection
			
			
			# behavior to control the splinter
			@splinter_behavior = MoveText.new
		end
		
		def add_to(mouse)
			super(mouse)
			
			@splinter_behavior.add_to mouse
		end
		
		# As long as one state creates a method,
		# then that method will be added to the list of methods accessible through Object#methods
		# thus, if any state adds a callback method,
		# that will modify the signature of this event handler
		
		state_machine :action_mode, :initial => :cut do
			# extract a new Text object from a highlighted segment
			state :cut do
				# Must drag out of the highlighted area to perform a cut
					# down (inside highlight)
					# hold (inside highlight)
					# hold and move to outside
					# release outside
				
				def click(selected)
					# pick
					puts "start cut"
					
					
					# from MoveText
					# establish basis for drag
					@move_text_basis = @mouse.position_in_world
					# store original position of text
					@original_text_position = selected.position
					
					
					# need this callback here so the pick starts,
					# even though there's probably not gonna be any logic here
					# @highlighted_segment = selected
					
					
					
				end
				
				
				def drag(selected)
					# move to new location
					
					# cancel move events
					@mouse.event_handlers.each do |event|
						if event.name == :move_text
							event.button_up_event
						end
					end
					
					
					
					# calculate movement delta
					delta = @mouse.position_in_world - @move_text_basis
					
					
					if dragged_outside_bb?
						# mouse dragged outside the boundaries of the highlighted segment
						
						# --- unlink the input buffer before anything else
						# NOTE:	if the cut occurs while the Text is connected to the input buffer,
						# 		then modifying the string with not have the desired effect,
						# 		as the buffer text is being rendered, and not the stored string
						selected.text.release
						selected.text.deactivate
						
						
						
						
						
						# --- process split
						string = selected.text.string
						
						# select highlighted text as string
						substring = string[selected.range]
						# clear substring from original text
						string[selected.range] = ""
						# create new text object from substring splintered from main text
						t = TextSpace::Text.new(selected.text.font)
						t.string = substring
							# copy style properties from original Text object
							[:height, :color, :box_color].each do |property|
								t.send "#{property}=", selected.text.send(property)
							end
						
						
						
						# add new text object to space
						@space << t
						# set @selection, so now this event system will move that bit around
						@selection = t
						
						
						# clear highlight
						@cut_selection.delete selected.text, selected.range
						
						
						
						# move the text from it's position in the text flow
						# to where the cursor was dragged
						# (intent is for the text to "pop" out of place)
						@original_text_position = selected.bb.position		# position in flow
						t.position = @original_text_position + delta		# offset by drag
						
						
						
						splinter
					end
				end
				
				def release(selected)
					
				end
			end
			
			# control the new splintered text
			state :splinter_manipulation do
				# if you're currently controlling the splinter segment,
					# just drag the splinter around, and ignore the highlight check
						# would really be ideal to just throw over to a MoveText#drag
						# current system does not support that
						# I wonder if there's any good way to do something like that?
				
				# def click(selected)
					# @splinter_behavior.click selected
				# end
				
				def drag(selected)
					# @splinter_behavior.drag selected
					
					delta = @mouse.position_in_world - @move_text_basis
					
					
					selected.position = @original_text_position + delta		# offset by drag
				end
				
				def release(selected)
					# no release behavior for MoveText
					# @splinter_behavior.release selected
					
					
					# release hold of the splinter
					
					# from MoveCaretAndSelectObject
					# @mouse.clear_selection
					
					# selected.click
					# selected.activate
					
					# @mouse.select selected
					
					
					reset
				end
			end
			
			
			
			event :splinter do
				transition :cut => :splinter_manipulation
			end
				after_transition any => :splinter_manipulation, :do => :create_splinter
			
			event :reset do
				transition any => :cut
			end
		end
		
		private
		
		# should this be down here as part of an edge callback,
		# or up there ^^^ where's it's done manually?
		def create_splinter
			# # split highlighted segment into new text object
			# # add new text object to space
			# # set @selection, so now this event system will move that bit around
			
			
			# @selection
			
			@splinter_behavior.click @selection
		end
		
		
		
		def dragged_outside_bb?
			# assumes that click callbacks start with the mouse inside of the bounding box
			!@selection.bb.contains_vect?(@mouse.position_in_world)
		end
	end
end