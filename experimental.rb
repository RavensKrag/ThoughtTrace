module Actions
	def edit_text(text)
		
	end

	def delete_text_object(space, text)
		
	end

	def select_single(text)
		
	end

	def select_multiple(text)
		
	end

	def spawn_new_text(space)
		
	end

	def select_portion_of_text(text)
		
	end

	def resize(text)
		
	end

	def move_text(text)
		
	end

	def pan_camera(camera)
		
	end
end

click do
	select_single
	# select_multiple
	
	edit_text
	delete_text_object
end

drag Gosu::MsLeft do
	case key
		when Gosu::MsLeft
			select_portion_of_text
		when Gosu::MsMiddle
			
		when Gosu::MsRight
			resize
	end
	
	
	move_text
end

drag do
	pan_camera
end

# -----
# Each action has separate click, drag, release sections
# the above format is good when callbacks are only in one type of mouse event,
# but that's not realistic.  Most actions need to be spread out between
# different types of mouse events
# -----
@mouse.selection_type :object_get do |space, selection, position_vector|
	# trigger on empty space
	obj = space.object_at position_vector
	
	return obj == nil
end

@mouse.selection_type :empty_space do |space, selection, position_vector|
	# trigger on empty space
	obj = space.object_at position_vector
	
	return obj == nil
end


@mouse.event :select_single do
	bind_to Gosu::MsLeft
	
	# TODO: need way to say if event should fire on blank, or when there's an object under the cursor
	# (allows for more complex event signatures, which makes it easier for the system to detect collision, instead of forcing the user to do it)
	
	fire :always
	fire :on_blank
	fire :on_object_get
	fire_on :any
	fire_on :all # for what events should we fire? fire on all events
	# how would :any and :all be different? should they just be "aliases" of the same command?
	fire_on :blank # no objects under cursor
	fire_on :hover # there's an object under the cursor, we haven't tried to pick yet
	fire_on :object_get
	
	fire_on :selction_active # one or more objects have already been selected
	fire_on :selction_empty # nothing currently selected
	
	
	launch_when :over_object
	launch_when_over :space
	launch_when_over :object
	
	# If block returns true, then events will fire
		# alternatively: return addition to selection or nil
			# means to clear current overall selection as well?
	# only checked for button down transition
	# after that, the rest of the cycle is guaranteed to complete
	select do |space, selection, position_vector|
		# trigger on empty space
		obj = space.object_at position_vector
		
		return obj == nil
	end
	
	
	
	
	# if the logic for mouse picking is going to be placed outside of these callbacks, need way to specifying what the logic is
	select :optimal
	select :all
	select :highest
	select :lowest
	select :largest_area
	select :smallest_area
	# allowing for multiple statements is more expressive than just saying "optimal"
	select :highest, :largest_area
	
	
	
	
	pick :object
		pick :object, :optimal
		pick :object, :highest, :largest_area
		
		pick :object do |objects|
			# objects - all objects in space under the mouse
			# return value of block is which objects to add to selection
			
			
			# within a certain margin of the smallest object
			# largest area, closest to mouse
		end
		
		
		
		
		
		# works similar to array methods like #select
		# iterates over all objects under the mouse
		# each and every object is passed into the block
		# if the block returns true, then that object is added to the selection
		pick :object do |objects|
			# objects - all objects in space under the mouse
			# return value of block is which objects to add to selection
		end
		
		
		# works similar to Array#sort
		# iterates over all objects under the mouse
		# block evaluates comparison between a and b
		# if there is only one object under the mouse, it is automatically added to the selection
		pick :object do |a, b|
			
		end
		
		
		
		pick :object do |objects, selection|
			
		end
		
	pick :point do |vector|
		# vector is in world space
	end
	
	
	
	
	click do |selection|
		# get object under cursor
		# add object to selection
		
		# save object so it can be de-selected later
	end
	
	drag do |selection|
		
	end
	
	release do |selection|
		# remove object from selection
	end
end

@mouse.event :move_text do
	bind_to Gosu::MsRight
	
	click do |selection|
		# select text under cursor
		# establish basis for drag
		# store original position of text
	end
	
	drag do |selection|
		# calculate movement delta
		# displace text object by movement delta
	end
	
	release do |selection|
		
	end
end

@mouse.event :spawn_new_text do
	bind_to Gosu::MsLeft
	
	click do |selection|
		# obj = $window.space.object_at position_vector
		# obj ||= $window.spawn_new_text
		
		obj = TextSpace::Text.new
		obj.position = @mouse.position_vector
		
		puts "new text"
		# obj.string = ["hey", "listen", "look out!", "watch out", "hey~", "hello~?"].sample
		
		@space << obj
		
		
		
		@selected = obj
		selection.add @selected
	end
	
	drag do |selection|
		
	end
	
	release do |selection|
		selection.remove @selected
	end
end

@mouse.event :pan_camera do
	bind_to Gosu::MsMiddle
	
	click do |selection|
		# Establish basis for drag
		@drag_basis = position_vector
	end
	
	drag do |selection|
		# Move view based on mouse delta between the previous frame and this one.
		mouse_delta = position_vector - @drag_basis
		
		$window.camera.position -= mouse_delta
		
		@drag_basis = position_vector
	end
	
	release do |selection|
		
	end
end



# @mouse.bind :move_text, Gosu::MsMiddle

@mouse[:move_text].button = Gosu::MsMiddle
# this syntax is basically saying the following:
alias :button=, :button
# as button(key) is already a method
# it makes it impossible to access the binding, using standard ruby convention


@mouse[:move_text].bind_to Gosu::MsMiddle # not sure if this should be publicly exposed or not
@mouse[:move_text].binding = Gosu::MsMiddle
@mouse[:move_text].binding # => Gosu::MsMiddle





# Equals syntax does not make sense when multiple kinds of binds can be generated,
# or when multiple buttons must be specified
@mouse[:move_text].bind_to Gosu::MsMiddle
@mouse[:move_text].bind_to Gosu::KbControl, Gosu::MsLeft
@mouse[:move_text].bind_to Gosu::MsRight, Gosu::MsLeft
# there's no way to specify difference between chord and sequence here
# this syntax only really works if sequences are not going to be supported
# even then, it might muddle up #bind_to considerably to do two rather different things





@mouse[:move_text].binding = ControlBinding::Button.new(Gosu::MsMiddle)
@mouse[:move_text].binding = ControlBinding::Chord.new(Gosu::MsMiddle)
@mouse[:move_text].binding = ControlBinding::Sequence.new(Gosu::MsMiddle)






# alternatively, have separate bind methods for different kinds of inputs
@mouse[:move_text].bind_to_button Gosu::MsMiddle
@mouse[:move_text].bind_to_chord Gosu::KbControl, Gosu::MsLeft
@mouse[:move_text].bind_to_sequence Gosu::MsRight, Gosu::MsLeft # drum fingers to the left
	# not sure that sequence binding is actually useful for mouse input the way it is for keyboard input, but when you consider that "mouse input" really only means "input that considers cursor position" and not "input based on physical buttons on the mouse", it could be useful
	# it's also useful from a design perspective to have the keyboard and mouse input systems have the same button binding API

# should still only need one output, though
@mouse[:move_text].binding
@mouse[:move_text].binding.is_a? ControlBinding::Button




# =====
# backend structure

# Evaluate events within the context of the event object
	# allows for separation of event object instance variables
	# prevents usage of methods as if they were magic variables

@events = {
	:identifier => EventObject(callbacks, binding)
}


# =====





@mouse.mouse_over do |selection, hovered|
	
end

@mouse.mouse_out do |selection, hovered|
	
end


# Maybe programatically test if two callbacks are colliding or not?
	# ex)	text selection and text move both are registered to click + drag on left mouse button
	# 		this is not allowable, because the system will not know what event to fire
# this isn't that hard
# only specify blocks for callbacks (out of click, drag, and release)
# that are necessary for the given event
# when the event is added to the collection
# test to see if there are any other events with the same footprint
	# maybe use bitvector or similar?
	# (110 is click and drag)
	# (101 is click and release)
	# (100 is just a click where you don't care about releasing)
# and the same button/key binding
# same footprint and same button results in a collision (as in hash collision)





# each mouse event should execute in it's own instance
# 	that way, no symbol collisions between variables
# section object passed to block
# in fact, all objects needed by a callback not local to that event should be passed in
# can be specified on event creation (in #event parameter list)
# would make dependencies between different events explicit



# buttons that will invoke state only when hold
# should have some visual indication they will bounce back
# maybe the button quivers when depressed?
# maybe the button resembles a physical material with that sort of springy property?
# hard to do this without kinesthetic / haptic feedback





# click on a piece of text to enter into edit mode, bringing up the input caret
# with an item selected, hit a button to delete it


# click and drag to highlight and select text the same way you would in any other program
	# like paint select
	# operates on the character-level
	
	# + control to add to current selection
# click and drag 


# object-level selection
# character-level selection






# text selection button must be different from text move button
# camera pan must have it's own button, because you need to be able to pan at all times
	# because you can perform this action at any time, it would be odd to have to dig through modifier to get to it





# left click select
# right click move
# middle click pan
# shift + click resize (because shift makes letters bigger (ie capital))