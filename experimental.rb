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
	
	
	
	
	
	selection_logic :optimal do |objects, selection|
		objects.sort! do |a, b|
			a.bb.area <=> b.bb.area
		end
		
		# Get the smallest area values, within a certain threshold
		# Results in a certain margin of what size is acceptable,
		# relative to the smallest object
		objects = objects.select do |o|
			# TODO: Tweak margin
			size_margin = 1.8 # percentage
			
			first_area = objects.first.bb.area
			o.bb.area.between? first_area, first_area*(size_margin)
		end
		
		objects.sort! do |a, b|
			distance_to_a = a.bb.center.dist position
			distance_to_b = b.bb.center.dist position
			
			# Listed in order of precedence, but sort order needs to be reverse of that
			[a.bb.area, distance_to_a].reverse <=> [b.bb.area, distance_to_b].reverse
		end
		
		selection.add objects.first
	end
	
	
	
	# -----Notes on pick-----
	# Events will only fire if the type of picking desired succeeds
		# ie) pick(:point) means that callbacks will only execute when an object has been selected
		# will not trigger on other picking conditions (like empty space)
	# only checked for button down transition
	# after that, the rest of the cycle is guaranteed to complete
		# also, remaining callbacks should receive the same picked item, so don't pick again
	# 
	# pick is for selecting objects within the space
	# callbacks like camera pan would not specify a pick callback,
	# as they do not need objects or space coordinates
	
	# only fires if the mouse is over empty space
	pick_object_from :point do |vector|
		# block must return a text object
	end
	
	# only fires if the mouse is over one or more objects
	pick_object_from :space do |object|
		
	end
	
	# only fires if mouse is over a member of the active selection
	pick_object_from :selection do |object|
		
	end
	
	
	# Alternatively, return just the point in space itself to the subsequent mouse callbacks
	pick_point_in :world_space
	pick_point_in :screen_space
	
	
	# would be nice for all pick_object_from methods to have the same return type
	# would be rather weird if that were not the case
	# but I suppose the effect of the method is more important than it's return type
	# seeing as how the return of the callback should never leak to the outside world
	
	
	def pick_object_from(domain, &block)
		# need to generate out when the callback launches, not on creation
		# but this shows the general idea
		out =	if domain == :point
					# point under cursor in world space
					
					position_vector
				else
					inital_selection_set = case domain
						when :space
							# best object as determined by space
							@space.objects
						when :selection
							# same query as space, but limit to selection, instead of whole space
							@selection
					end
					
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
					selection = inital_selection_set.select do |o|
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
					
					
					selection.first
				end
		
		
		# save the out for later
		# save the block for later
		# pass the out to the block when the block is called
		# 
		# if the 
		block.call out if block != nil
		
		return nil # reveal no data to outside systems
	end
	
	
	
	# pick_object_at :point
	# pick_object_in :space
	# pick_object_from :selection
	
	# pick object based on this point
	# pick object from point
	
	# pick object from space
	# pick object from out of this space
	
	# pick object from selection
	# pick object out of this selection
	
	
	
	# pick_object_at :space
	# pick_object_in :space
	# pick_object_from :space
	
	
	
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
	
	pick_object_from :space do |object|
		
	end
	
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
	
	pick_object_from :point do |vector|
		obj = TextSpace::Text.new
		obj.position = vector
		# obj.string = ["hey", "listen", "look out!", "watch out", "hey~", "hello~?"].sample
		puts "new text"
		
		
		selection.clear
		selection.add obj
	end
	
	click do |selection|
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



# this syntax allows for spitting up callbacks between separate files
class MouseEvent
	def initialize
		@name = self.name.scan(/(.*)[Event]*/)[0][0].to_snake_case.to_sym
	end
	
	def add_to(handler)
		# 
		
		
		
		# set other variables here as well,
		# so events can be initialized without parameters
		# but all the events in the same handler can point to the same values
		@space = handler.space
		
		@color = handler.paint_box
	end
end

class TextBoxEvent < MouseEvent
	# must state key bindings as symbols, rather than variables
	# will scan the input system for a sequence with the given symbol as the name
	# (really just needs to be the same unique identifier as used for the sequence)
	bind_to :left_click
	pick_object_from :space
	
	def initialize
		super()
	end
	
	def click(selected)
		@text_box_top_left = position_in_world
	end
	
	def drag(selected)
		bottom_right = position_in_world
		
		bb = CP::BB.new(@text_box_top_left.x, bottom_right.y, 
						bottom_right.x, @text_box_top_left.y)
		bb.reformat # TODO: Rename CP::BB#reformat
		
		bb.draw_in_space @color[:box_select]
	end
	
	def release(selected)
		
	end
end

# could maybe defined singleton methods if you want a single-file interface
x = Event.new
	x.click do
		
	end
	x.drag do
		
	end
	x.release do
		
	end



# to disable, you can just comment out one line
@mouse = MouseHandler.new @space, @selection, @paint_box
@mouse.add(
	TextBoxEvent.new,
	# SpawnNewTextEvent.new,
	MoveCaretEvent.new
)



# major problem right now is how to deal with saving / loading event bindings
	# could get really weird if the bindings in the class declaration
	# can be different from the actual bindings being used,
	# but only like, under certain circumstances?
	# what would those event be?



# maybe the set should happen in the mouse?
	# then, this class need only expose the things necessary to figure out what to bind to
	# the binding may fail due to a collision with another event in the mouse handler,
	# so it actually makes a lot of sense to do it that way

# how should collisions be handeled?
# should collisions with the general input system be checked first,
# or is it more important to test collisions of mouse-specific features?
	# seems like it should test mouse specific features first,
	# then let the rest of the input system catch other problems






class BoxSelect
	attr_accessor :selected
	
	def initialize
		super() # set up state machine
	end
	
	def pick(domain, point)
		# NOTE: could just return the picked value instead of setting it to variable
		# in order of priority (high to low)
		
		# --- selection pick
		# pick from a group of objects
		@selected = SelectionQueries.point_query(@selection, point)
		# @selected = @selection.point_query point
		
		
		
		# --- space pick
		# pick one object out of the space
		@selected = SelectionQueries.point_query(@space, point)
		
		
		
		# --- point pick 
		# project a point into the space, and create a new object there
		obj = TextSpace::Text.new
		obj.position = point
		@selected = obj
		
		
		enable
	end
	
	
	private
	
	def on_press
		puts "box"
		@box_top_left = @mouse.position_in_world
		
		@box_selection = Set.new
	end
	
	def on_hold
		bottom_right = @mouse.position_in_world
		
		bb = CP::BB.new(@box_top_left.x, bottom_right.y, 
						bottom_right.x, @box_top_left.y)
		bb.reformat # TODO: Rename CP::BB#reformat
		
		bb.draw_in_space @color[:box_select]
		
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
	
	def on_release
		@box_selection.each do |obj|
			obj.mouse_out
		end
	end
	
	
	public
	
	
	state_machine :state, :initial => :idle do
		state :idle do
			def update
				
			end
		end
		
		state :holding do
			def update
				on_hold
			end
		end
		
		
		event :press do
			transition :idle => :holding
		end
		
		event :release do
			transition :holding => :idle
		end
		
		after_transition :idle => :holding, :do => :on_press
		after_transition :holding => :idle, :do => :on_release
	end
end


class Mouse
	def add
		
	end
	
	def bind
		
	end
end





event = BoxSelect.new

@selected = event.pick(@space, CP::Vec2.new($window.mouse_x, $window.mouse_y))

event.activate(@selected)
event.hold(@selected)
event.release(@selected)



# this has much lower noise, as you only need to specify
# the value of event.selected when the value changes,
# not ALL THE TIME
event = BoxSelect.new

@selected = event.pick(@space, CP::Vec2.new($window.mouse_x, $window.mouse_y))

event.selected = @selected

event.activate
event.hold
event.release



# typical external interface
# still should be able to reach into the inner callbacks, for event composition
event.pick()
event.update


event.enable
event.update
event.disable










@mouse.bind BoxSelect.new, left_click


# this style is elegant (no bind and rebind)
# this style also facilitates loading from external source
@mouse.add :box_select, BoxSelect.new
@mouse.bind :box_select, left_click

# want to bind an action, but no bind read from file
# toss it into a pile of unbound actions
@mouse.add :cut_text, CutText.new
@mouse.bind :cut_text, Mouse::UNBOUND


# this takes advantage of 1.class.name == "Fixnum"
@mouse.add CutText.new
@mouse.bind 'CutText', Mouse::UNBOUND

# could just identify the event by the class name
# side effect is that you can only have one instance of each class
@mouse.add CutText.new
@mouse.bind CutText, Mouse::UNBOUND 






@actions = {
	:cut_text => CutText.new
}
@mouse.bind @actions[:cut_text], left_click




@actions = ActionGroup.new
@actions.add(
	CutText.new
)


left_click
middle_click
right_click

# either
	@mouse.track @actions[CutText]
	@mouse.bind CutText, left_click # check for collisions on this step

# or
	@mouse.bind @actions[CutText], left_click # check for collisions on this step
	
	# second argument can be optional, if you want to "bind" an action,
	# but don't know what key to bind it to
	# really want to lean heavily on using the graph system to assign bindings,
	# instead of binding in a text file






@actions = ActionGroup.new
@actions.add(
	CutText.new
)

@mouse = Mouse.new @inpman
@mouse.bind @actions[CutText], :left_click

# hopefully, the Mouse class will only facilitate connections
# between input events and actions, and wont' have to actually
# do much connecting between events at all.
# This would be great for parallelism
# (though, parallelism is pretty much impossible in Ruby... so yeah)
	
