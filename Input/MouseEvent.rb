# taken from rails, courtesy of StackExchange
# http://stackoverflow.com/questions/1509915/converting-camel-case-to-underscore-case-in-ruby
class String
  # def underscore
  def to_snake_case
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end


module MouseEvents
	class EventObject
		# must state key bindings as symbols, rather than variables
		# will scan the input system for a sequence with the given symbol as the name
		# (really just needs to be the same unique identifier as used for the sequence)
		bind_to :left_click
		pick_object_from :space
		
		def initialize
			super() # needed for state_machine
			
			# Set up event structure
			
			# may want to consider trying to refactor the code so initialization is unnecessary
			# this would allow for this to be declared as a mixin
			# which would be nice, because you should really not be able to create
			# instance of this class directly, as part of the interface is not implemented
			
			@name = self.name.scan(/(.*)[Event]*/)[0][0].to_snake_case.to_sym
			
			@binding = nil
		end
		
		def add_to(mouse_system)
			@mouse = mouse_system
			
			
			# set other variables here as well,
			# so events can be initialized without parameters
			# but all the events in the same handler can point to the same values
			@space = mouse_system.space
			
			@color = mouse_system.paint_box
		end
		
		# Do not define the callback methods, but expect that children of this class will
		# This is so you can tell which callbacks have been defined
		
		# def click(selected)
			
		# end
		
		# def drag(selected)
			
		# end
		
		# def release(selected)
			
		# end
		
		
		
		
		
		EVENT_TYPES = [:click, :drag, :release]
			
		# Evaluate collision between this object and other
		# 
		# iterate through properties trying to disambiguate
		# if you hit the end of properties list, and callback still ambiguous,
		# collision has occurred
		def collide_with(other, fields_to_check=([:binding, :pick_callback] + EVENT_TYPES))
			# property must be defined on both sides
			# if it's only defined on one side, then it's not a collision,
			# (should be able to disambiguate by difference)
			other_sig = other.signature
			sig = self.signature
			
			colliding_fields = Array.new
			
			collision_occured = fields_to_check.all? do |property|
				puts property
				
				value = sig[property]
				other_value = other_sig[property]
				
				if other_value && value
					# --- property defined on both sides ---
					
					# possibility of collision
					
					# collision if one or more of the properties which are defined on both sides are set to equivalent values
					
					# General case
					if other_value == value
						puts "=== collide ==="
						
						colliding_fields << property
						
						true
					else
						# Special cases
						if( 
						property == :pick_callback and
							# Space picking collides with selection picking
							(other_value == :space && value == :selection or
							value == :space && other_value == :selection)
						)
							# NOTE: Could return a tuple and say "priority to :selection"
							# or ":priority => :selection"
							# would have to change the whole return type system of this method though
							puts "=== collide (special case) ==="
							
							colliding_fields << property
							
							true
						else
							# Special cases have failed, so no collision detected
							puts "--- different (#{value} vs #{other_value})"
							
							false
						end
					end
				elsif !!other_value ^ !!value
					# --- only defined on one side or the other ---
					
					# no collision
					puts "+++ different (signature mismatch)"
					return false # short circuit
				else
					# --- triggers when both are undefined ---
					
					# continue to check for collision
					puts ">>> continue"
					
					true
				end
			end
			
			
			# Return collision result
			if collision_occured
				if colliding_fields.empty?
					return nil
				else
					return colliding_fields
				end
			else
				return false
			end
		end
		
		# Should be able to compare the signatures of two ButtonEvent objects
		# to see if there will be any sort of collision of the event callbacks
		# TODO: Consider only implementing equality tests, and not having #signature
		def signature
			output = Hash.new
			# {
			# 	:binding => @binding / nil
			# 	:pick_callback => @pick_domain / nil # type of callback, not the actual block
			# 	:click => true / false
			# 	:drag => true / false
			# 	:release => true / false
			# }
			
			output[:binding] = @binding
			
			output[:pick_callback] = @pick_domain if @pick_object_callback_defined
			
			EVENT_TYPES.each do |e|
				output[e] = @callbacks[e] ? true : false
			end
			
			
			return output
		end
		
		state_machine :state, :initial => :up do
			state :up do
				def update
					
				end
				
				def click_event
					# preventing transition out of the "up" state
					# prevents click, drag, and release events from firing
					# by locking the state machine in the up state, where
					# the release event is stubbed,
					# and no callbacks are launched
					
					# only proceed if defined pick callbacks have fired
					a = pick_callback_defined?
					b = pick_object_callback
					
					# a b		out
					# 0 0		1		# callback undefined
					# 0 1		1		# 
					# 1 0		0		# if it's defined, it must have fired properly
					# 1 1		1		# 
					
					if (!a || b)
						click_callback
						
						button_down_event
					end
				end
				
				def release_event
					
				end
			end
			
			state :down do
				def update
					drag_callback
				end
				
				def click_event
					
				end
				
				def release_event
					release_callback
					
					
					button_up_event
				end
			end
			
			
			event :button_down_event do
				transition :up => :down
			end
			
			event :button_up_event do
				transition :down => :up
			end
		end
		
		
		
		# Select object to be manipulated in further mouse callbacks
		def pick_object_from(domain, &block)
			@pick_domain = domain
			@pick_callback = block
		end
		
		def pick_object_callback
			# This callback should not fire when domain undefined
			return unless pick_callback_defined?
			
			
			point = @mouse.position_in_world
			
			object = @mouse.space.object_at point
			
			picked = case @pick_domain
				when :space
					object
				when :selection
					# object if selection.include? object
				when :point
					# add object generated as result of block to space automatically
					# this should remove the need to expose the space to mouse callbacks
					point if object == nil # only fire in empty space
				else
					raise "Invalid mouse picking domain (choose :point, :space, or :selection)"
			end
			
			
			# NOTE: This means selections are separate for each mouse event
			
			
			# --- (if defined callback does not fire)
			# is the a chance for callback to fire where no valid element is picked?
			# NO
			
			# valid insures callback executed?
			# essentially (unless there's no callback block defined)
			
			
			@selection =	if picked
								if @pick_callback
									out = @mouse.instance_exec picked, &@pick_callback
									
									if @pick_domain == :point
										@mouse.space << out
									end
									
									out
								else
									picked
								end
							else
								nil
							end
		end
		
		def pick_callback_defined?
			# return truthyness
			return !!@pick_domain
		end
		
		EVENT_TYPES.each do |event|
			# Fire callbacks
			define_method "#{event}_callback" do ||
				if @callbacks[event]
					@mouse.instance_exec @mouse.space, @selection, &@callbacks[event]
				end
			end
			
			# Interface to define callbacks
			define_method event do |&block|
				@callbacks[event] = block
			end
		end
		
		
		# TODO: make sure bindings can be defined in an interface on Mouse, but that event firing is handled by the input system
		
		
		# Manage button binding
		def bind_to(binding)
			# remove previous binding, if any
			@binding.callbacks.delete @name if @binding
			
			# set up new binding
			@binding = binding
			
			
			# should just use the name of the mouse event,
			# that way you don't have to define two names
			@binding.callbacks[@name].tap do |c|
				c.on_press do
					click_event
				end
				
				c.on_hold do
					
				end
				
				c.on_release do
					release_event
				end
				
				# c.on_idle do
					# hover?
				# end
			end
		end
		alias :binding= :bind_to
		
		
		def binding
			@binding
		end
		
		
		private
		
		# TODO: Remove this method.  Merge with Space#object_at
		def pick_from(selection, position)
			# TODO: This method should belong to a selection class
			# arguably the selection code should belong to the selection,
			# as would be oop style
			# that means that any partition of the space (including the whole space)
			# needs to be considered a selection
			
			
			
			# Select objects under the mouse
			# If there's a conflict, get smallest one (least area)
			
			# There should be some other rule about distance to center of object
				# triggers for many objects of similar size?
				
				# when objects are densely packed, it can be hard to select the right one
				# the intuitive approach is to try to select dense objects by their center
			selection = selection.select do |o|
				o.bb.contains_vect? position
			end
			
			selection.sort! do |a, b|
				a.bb.area <=> b.bb.area
			end
			
			# Get the smallest area values, within a certain threshold
			# Results in a certain margin of what size is acceptable,
			# relative to the smallest object
			selection = selection.select do |o|
				# TODO: Tweak margin
				size_margin = 1.8 # percentage
				
				first_area = selection.first.bb.area
				o.bb.area.between? first_area, first_area*(size_margin)
			end
			
			selection.sort! do |a, b|
				distance_to_a = a.bb.center.dist position
				distance_to_b = b.bb.center.dist position
				
				# Listed in order of precedence, but sort order needs to be reverse of that
				[a.bb.area, distance_to_a].reverse <=> [b.bb.area, distance_to_b].reverse
			end
			
			
			return selection.first
		end
	end	
end

#     _   __                ______                 __     ____        __  __                
#    / | / /__ _      __   / ____/   _____  ____  / /_   / __ \____ _/ /_/ /____  _________ 
#   /  |/ / _ \ | /| / /  / __/ | | / / _ \/ __ \/ __/  / /_/ / __ `/ __/ __/ _ \/ ___/ __ \
#  / /|  /  __/ |/ |/ /  / /___ | |/ /  __/ / / / /_   / ____/ /_/ / /_/ /_/  __/ /  / / / /
# /_/ |_/\___/|__/|__/  /_____/ |___/\___/_/ /_/\__/  /_/    \__,_/\__/\__/\___/_/  /_/ /_/ 
# module MouseEvents
# 	class Test < MouseEvent
# 		bind_to :left_click
# 		pick_object_from :space
		
# 		def initialize
# 			super()
# 		end
		
# 		def click(selected)
			
# 		end
		
# 		def drag(selected)
			
# 		end
		
# 		def release(selected)
			
# 		end
# 	end
# end


# MouseEvents::Test.new





f_keys = (1..8).collect{ |i| "KbF#{i}".to_sym }.collect{ |s| Gosu.const_get(s) }
f_keys.each do |key|
	class_name = "change_color_to_swatch-#{key}"
	
	new_class =		Class.new(MouseEvent) do
						bind_to key
						
						pick_object_from :space
						
						def click(text)
							text.color = @paint_box[key]
						end
					end
	
	MouseEvents.const_set(class_name, new_class)
end




# class DeleteTextObjectEvent < MouseEvent
# 	bind_to :left_click
# 	pick_object_from :space
	
# 	def initialize
# 		super()
# 	end
	
# 	def click(selected)
		
# 	end
	
# 	def drag(selected)
		
# 	end
	
# 	def release(selected)
		
# 	end
# end

# class SelectSingleEvent < MouseEvent
# 	bind_to :left_click
# 	pick_object_from :space
	
# 	def initialize
# 		super()
# 	end
	
# 	def click(selected)
# 		# get object under cursor
# 		# add object to selection
		
# 		# save object so it can be de-selected later
# 	end
	
# 	def drag(selected)
		
# 	end
	
# 	def release(selected)
# 		# remove object from selection
# 	end
# end


# class SelectMultipleEvent < MouseEvent
# 	bind_to :left_click
# 	pick_object_from :space
	
# 	def initialize
# 		super()
# 	end
	
# 	def click(selected)
		
# 	end
	
# 	def drag(selected)
		
# 	end
	
# 	def release(selected)
		
# 	end
# end




class TextBoxEvent < MouseEvent
	bind_to :left_click
	pick_object_from :space
	
	def initialize
		super()
	end
	
	def click(selected)
		# generate basis for box
		# spawn caret?
		@text_box_top_left = position_in_world
	end
	
	def drag(selected)
		# stretch box extents
		bottom_right = position_in_world
		
		bb = CP::BB.new(@text_box_top_left.x, bottom_right.y, 
						bottom_right.x, @text_box_top_left.y)
		bb.reformat # TODO: Rename CP::BB#reformat
		
		bb.draw_in_space @color[:box_select]
	end
	
	def release(selected)
		# cement box constraints
		# enable box for editing
	end
end


class SpawnNewTextEvent < MouseEvent
	bind_to :left_click
	pick_object_from :point do |vector|
		puts "new text"
		obj = TextSpace::Text.new
		obj.position = position_in_world
		
		obj
	end
	
	def initialize
		super()
	end
	
	def click(selected)
		clear_selection
		
		selected.click
		selected.activate
		
		select selected
	end
	
	# def drag(selected)
		
	# end
	
	# def release(selected)
		
	# end
end


class MoveCaretAndSelectObjectEvent < MouseEvent
	bind_to :left_click
	pick_object_from :space
	
	def initialize
		super()
	end
	
	def click(selected)
		clear_selection
		
		selected.click
		selected.activate
		
		select selected
	end
	
	# def drag(selected)
		
	# end
	
	# def release(selected)
		
	# end
end

class HighlightTextEvent < MouseEvent
	bind_to :shift_left_click
	pick_object_from :space
	
	def initialize
		super()
	end
	
	def click(selected)
		# get position of character at mouse position
		i = text.closest_character_index(position_in_world)
		@starting_character_offset = text.character_offset i
	end
	
	def drag(selected)
		# extend selection from there
		
		# NOTE: selection should always go from left-most character to right-most
		# if the selection is made from right to left, this will invert things
		# this issue is similar to the one with drawing BBs encountered for box select
		
		i = text.closest_character_index(position_in_world)
		character_offset = text.character_offset i
		
		
		height = text.height # pixels
		
		offset = text.position.clone
		offset.y += height / 2
		
		p0 = @starting_character_offset + offset
		p1 = character_offset + offset
		
		bb = CP::BB.new(p0.x, p0.y-height/2, 
						p1.x, p1.y+height/2)
		bb.reformat # TODO: Rename CP::BB#reformat
		
		bb.draw_in_space @paint_box[:highlight]
	end
	
	# def release(selected)
		# free selection
	# end
end

class HighlightTextEvent < MouseEvent
	bind_to :shift_left_click
	pick_object_from :space
	
	def initialize
		super()
	end
	
	def click(selected)
		
	end
	
	def drag(selected)
		
	end
	
	# def release(selected)
		
	# end
end

class ResizeEvent < MouseEvent
	bind_to :shift_right_click
	pick_object_from :space
	
	def initialize
		super()
	end
	
	def click(selected)
		@first_position = selected.position
		@resize_basis = position_in_world
		
		@screen_position = position_on_screen
	end
	
	def drag(selected)
		# TODO: Only drag if delta exceeds threshold to prevent accidental drag from click events.  Delta in this case should be measured screen-relative
		screen_delta = position_on_screen - @screen_position
		
		if screen_delta.length > 2
			selected.height = position_in_world.y - selected.position.y
		end
	end
end

class MoveTextEvent < MouseEvent
	bind_to :right_click
	pick_object_from :space
	# pick_object_from :space do |object|
	# 	object
	# end
	
	def initialize
		super()
	end
	
	def click(selected)
		# select @drag_selection
		# establish basis for drag
		@move_text_basis = position_in_world
		# store original position of text
		@original_text_position = selected.position
	end
	
	def drag(selected)
		# calculate movement delta
		delta = position_in_world - @move_text_basis
		# displace text object by movement delta
		selected.position = @original_text_position + delta
	end
	
	# def release(selected)
		
	# end
end

class CutTextEvent < MouseEvent
	bind_to :right_click
	pick_object_from :selection
	
	def initialize
		super()
	end
	
	def click(selected)
		# pick
	end
	
	def drag(selected)
		# move to new location
	end
	
	def release(selected)
		# deselect new text object formed from cut
	end
end

class PanCameraEvent < MouseEvent
	bind_to :middle_click
	
	def initialize
		super()
	end
	
	def click(selected)
		# Establish basis for drag
		@pan_basis = position_in_world
	end
	
	def drag(selected)
		# Move view based on mouse delta between the previous frame and this one.
		mouse_delta = position_in_world - @pan_basis
		
		$window.camera.position -= mouse_delta
		
		@pan_basis = position_in_world
	end
	
	def release(selected)
		
	end
end

class BoxSelectEvent < MouseEvent
	bind_to :shift_left_click
	
	# if you don't use a pick query, it can execute any time
	
	# that means this currently executes currently with resize
		# (This was with old bindings. It is not true any more)
		# (But this collision problem may still be valid)
	# fire :in_empty_space
	# fire :over_object # over something, idk what it is, you won't have access to it
	
	def initialize
		super()
	end
	
	def click(selected)
		puts "box"
		@box_top_left = position_in_world
		
		@box_selection = Set.new
	end
	
	def drag(selected)
		bottom_right = position_in_world
		
		bb = CP::BB.new(@box_top_left.x, bottom_right.y, 
						bottom_right.x, @box_top_left.y)
		bb.reformat # TODO: Rename CP::BB#reformat
		
		bb.draw_in_space @paint_box[:box_select]
		
		# Perform selection using BB
		new_selection = Set.new
		
		@space.bb_query(bb).each do |obj|
			obj.mouse_over
				
			new_selection.add obj
		end
		
		(@box_selection - new_selection).each do |obj|
			obj.mouse_out
		end
		
		@box_selection = new_selection
	end
	
	def release(selected)
		@box_selection.each do |obj|
			obj.mouse_out
		end
	end
end
