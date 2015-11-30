module ThoughtTrace


# Controls overall execution flow for all input systems.
# Like a main method for the entire input system.
# 
# As it is a "main", this class is more a portion of ThoughtTrace proper,
# rather than something than can be externalized.
# This is reflected in the module chosen to hold this class.

















# what happens when you press multiple buttons?
# left   - edit
# right  - move
# middle - camera

# camera actions can be combined with in-space entity actions
# but you don't really want multiple actions on entities happening at the same time

# so, the constraint is about overlap in action types,
# it's not really about button mappings at all


# raw input -> complex input events -> actions that effect the document

require 'roo'

class InputManager
	# TODO: control mouseover effects from this class as well
	
	attr_reader :mouse, :buttons
	
	def initialize(window, document)
		@window = window
		
		# TODO: should probably just pass the window and the document
		# TODO: take note of what things would need to be updated if the bound document were to shift
		@document = document
		
		# TODO: need to figure out if the document (and enclosed data) should be passed to subsystems as they are initialized, or only as they need them.
			# latter would allow for changing the document more freely,
			# but maybe the whole input system just needs to be refreshed
			# when you have a new document?
		
		# TODO: properly implement mouse.
		@mouse = InputSystem::Mouse.new window, @document.camera
		
		
		@keyboard = InputSystem::Keyboard.new window
		
		
		# TODO: figure out if the selection Group needs to be added to the Space or something. How are Groups being tracked?
		@selection = InputSystem::Selection.new @document
		
		@text_input = ThoughtTrace::TextInput.new
		
		
		
		
		# manages many input events
		# input events correspond to button presses
		# those buttons can be keyboard keys, mouse buttons, or gamepad buttons
		@buttons = InputSystem::ButtonParser.new
		
		
		# hold actions flow controllers, so that input manager can direct action UI drawing
		# need to draw actions so that they can show polymorphic interface information
		# NOTE: storing actions this way means that the button parser doesn't have to know anything about the input system.
		@actions = Array.new
		
		
		# TODO: consider moving the action factory into the Document, if it would somehow make document switching easier to just bind the action factory present inside each document, instead of having to re-init the factories. But maybe that structure just doesn't work for some reason.
		@action_factory = InputSystem::ActionFactory.new(
							@selection,
							
							:selection => @selection,
							:text_input => @text_input,
							
							:space => @document.space,
							:clone_factory => @document.prototypes,
							:styles => @document.named_styles
						)
		
		@action_history = Array.new
		# TOOD: consider using more advanced data structure for history
		@redo_stack = Array.new
		
		@null_action = ThoughtTrace::Actions::NullAction.new
		
		
		
		
		
		
		

		# input bindings
		
		
		# NOTE: currently want to declare target type here, because it makes it easier to see the full binding relationships in one place. Makes it clearer if you want to effect only one type of Entity.
		
		filepath = "/home/ravenskrag/Code/Tools/ThoughtTrace/notes/input_bindings.ods"
		@mouse_bindings = load_mouse_binding_config(filepath, "Mouse Bindings")
		
		
		# mouse wheel
			# zoom                ( zoom the entire document. images GPU scale, text smart scale )
			# abstraction layer   ( ladder of abstraction: explicit detail vs high-level )
			# render layer        ( relative z-index depth sort. swap z-index with other items. )
		
		
		# edit action only edits exposed properties,
		# if you peel the abstraction back, you can edit individual properties
		# ie) move a vert with the move action
		
		# abstraction stepping works on a particular tree-like segment of the graph.
		# on any one element in the tree you can...
		# + step up:    limits the whole tree to view the parent layer ( for that subgraph )
		# + step down:  expands the view to include the children of that node
		
		@mouse_wheel_actions = {
				[]                        => [:zoom],
				[:shift]                  => [:render_layer],
				[:control]                => [:abstraction_layer],
				[:alt]                    => [nil],
				[:shift, :control]        => [nil],
				[:shift, :alt]            => [nil],
				[:control, :alt]          => [nil],
				[:shift, :control, :alt]  => [nil]
		}
		
		
		
		# keyboard input split into various types
		# - text input
		# - accelerators
		# - non-text keys that perform context-sensitive actions
		# 
		# - maybe some other categories?
		@keyboard_bindings = {
			Gosu::KbF5 => :link_styles,
			# all selected items now use the same style
			
			
			Gosu::KbReturn => :new_line,
			# creates new line of text when there is an active text object
			
			
			Gosu::KbF7 => :undo,
			Gosu::KbF8 => :redo
		}
		# NOTE: not currently using @keyboard_bindings.
		
		
		
		
		# mouse actions
			# click and drag
			# different states with updating looping flow
			# modified by keyboard state
			# launch Actions that can be called through other mechanisms
		# mouse wheel actions
			# may change variables that effect other actions
			# affects user interface layer, but not the way raw Actions are triggered
		# keyboard actions
			# single button press causes something to happen
			# should also be undo-able
			# not sure if these are Action or just Events
			# can affect the current selection
				# can they effect more than that?
		
		
		
		
		
		# NOTE: Action names and Event names may not necessarily have the same requirements.
		# Action names
		# 	Control what sort of action will be fired
		# 	Like methods, specifics are resolved with polymorphism
		# Event names
		# 	unique ID for this specific Event
		# 	must be distinct among keyboard, mouse, joystick etc events
		# 	each Event is one combination of (name, binding, callback)
		# 	thus, it is possible for many events to trigger one Action
		# 	because you want multiple bindings on one Action
		# 	(thing mouse bindings vs keyboard, rather than multiple keyboard shortcuts)



		# TODO: clean up mouse action flow classes. Many of them are no longer needed.
		# TODO: clean up button input system to synergize with new accelerator system
		
		
		
		# events weren't DESIGNED this way,
		# but turns out that you only need to press AT LEAST what's specified to fire an event
		# thus, "click + control" will trigger events bound to "click + [NO MODIFIERS]"

		# should consider splitting out modifiers into a separate system
		# separate from the core press-hold-release and raw button abstraction logic
		
		
		
		
		
		
		
		
		
		# === new plan ===
		# inputs bound to actions
		# each input binding triggers a separate action
		# actions can be targeted or non-targeted (should specify on the action)
		# if an action is targeted, then the input system will grab an appropriate target
		# and feed it in to the action at the proper phase
		
		# are there specific types of targets?
		
		
		
		# --proposal:
		# use 'join' action to add new entities into a group
		# use 'split/rip' to remove entities from a group
		# (not literally the same actions, just this name)
		# these names originally are for manipulating substrings in strings
		# it makes sense to extend that functionality to entity / group relationships
		
		
		
		@foo = ThoughtTrace::GetAction.new({
					:selection => @selection,
					:text_input => @text_input,
					
					:space => @document.space,
					:clone_factory => @document.prototypes,
					:styles => @document.named_styles
		})
		
		
		# one active action per button?
		
		
		
		# left and right activate at the same time (same frame startup. unlikely but possible)
		# left activates when right is active
		# right activates when left is active
		# => in any of these cases only one action at most can be active.
		# when you can't disambiguate, fire no actions at all
		
		
		
		# want to make sure you can move the camera while manipulating objects,
		# but you don't want two object manipulation actions occurring simultaneously
		# what exactly should be the course of action in that case?
		# you are certainly physically capable of hitting both buttons at once,
		# so this scenario MUST be considered
		
		
		
		
		
		# control: constraint mode ( drag for constraint, click for query? kinda makes sense )
		# alt:     selection mode  ( selection and groups are pretty much the same thing )
		# shift:   extra modifier - mode dependent
		
		# control + alt = query? (queries are kinda like constraints, and they select things...)
		
		
		# NOTE: need Entity type 'image'
		# NOTE: spawning new Entities has been removed from input bindings. Should use duplication of existing things, or drag in items from the prototype list.
		# TODO: implement prototype list UI system.
		
		# NOTE: it's not really 'empty space' binding as much as it is 'no entity target' binding. Should probably update the system to reflect that. Shouldn't have to declare things that require no target twice.
		
		
		
		@mouse_inputs = [
			[:left_click,   Gosu::MsLeft],
			[:right_click,  Gosu::MsRight],
			[:middle_click, Gosu::MsMiddle]
		]
		@mouse_inputs.each{|arr| arr << InputSystem::MouseInputSystem.new(@mouse) }
		# you need a separate instead for each button
		# each MouseInputSystem instance stores one press-hold-release / click-drag flow
		
		
		# foo_x234 = Hash.new
		# foo_x234[:proc_foo1] = ->(){
		# 	@mouse.position_in_space
		# }
		# foo_x234[:proc_foo2] = ->(){
		# 	@mouse.position_on_screen
		# }
		
		# mouse  - default coordinates: screen space
		# entity - default coordinates: world space
		# need a way to take any object at all in the system that has a position in some space,
		# and say "what is your position, and what coordinate space are you in"
		# such that you can convert between any given coordinate space to any other
		# 
		# may have to delay solving this problem until we have a basic graph drawing system.
		# can always just tack on some solution for now and make a better one later.
		# (create graph with coordinate spaces and their relationships, then find shortest paths)
		
		# I think both click and drag phases need to use the same coordinate space, otherwise things get really weird
		
		
		@mouse_inputs.each do |mb, button_id, mouse_input_system|
			event = InputSystem::ButtonEvent.new(mb, mouse_input_system)
			event.bind_to keys:[button_id], modifiers:[]
			@buttons.register event
			
			
			# returns the mouse position in an appropriate coordinate space for the desired Action
			mouse_input_system.mouse_position_callback do |phase|
				if mb == :middle_click
					@mouse.position_on_screen
				else
					@mouse.position_in_space
				end
			end
			
			mouse_input_system.parse_callback do |phase, point|
				# this block needs to return an initialized Action object
				# (do NOT call press yet)
				
				# NOTE: add debug print statement to show the current inputs
				# (mouse button, accelerators, click / drag)
				# when no action is bound
				# (functionality from current MouseInputSystem that I'm about to break)
				
				
				accelerators = @keyboard.active_accelerators
				
				name_and_target = @mouse_bindings[mb][accelerators][phase]
				
				action_name = name_and_target[:action]
				target_type_string = name_and_target[:target]
				
				
				action = @foo.foo(@document, point, action_name, target_type_string)
			end
			
			
			mouse_input_system.finishing_callback do |action|
				@action_history << action unless action.is_a? ThoughtTrace::Actions::NullAction
				@redo_stack.clear
				
				
				print_history()
			end
		end
		
		
		
		@mouse_actions = @mouse_inputs.collect{|arr| arr.last }
		
		
		
		
		
		
		
		
		
		
		# mouse wheel
		# 	zoom                ( zoom the entire document. images GPU scale, text smart scale )
		# 	abstraction layer   ( ladder of abstraction: explicit detail vs high-level )
		# 	render layer        ( relative z-index depth sort. swap z-index with other items. )


		# edit action only edits exposed properties,
		# if you peel the abstraction back, you can edit individual properties
		# ie) move a vert with the move action

		# abstraction stepping works on a particular tree-like segment of the graph.
		# on any one element in the tree you can...
		# + step up:    limits the whole tree to view the parent layer ( for that subgraph )
		# + step down:  expands the view to include the children of that node
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		# press button, retrieve action, fire immediately
		
		
		# TODO: need to find a way to move the launch predicate into the Action itself.
		# key ID, action name, launch predicate, action target (explicit object)
		foo_x = [
			[Gosu::KbReturn, @text_input,       :new_line,    ->(){ @text_input.active? } ],
			[Gosu::KbF5,     @selection.group,  :link_styles, ->(){ !@selection.empty? }  ]
		]
		foo_x.each{|arr| arr << ThoughtTrace::Events::PressButton.new }
		
		
		
		foo_x.each do |button_id, action_target, action_name, launch_predicate, handler|
			event = InputSystem::ButtonEvent.new(action_name, handler)
			event.bind_to keys:[button_id], modifiers:[]
			@buttons.register event
			
			
			
			handler.set_callback do
				action = 
					if launch_predicate.call()
						@foo.baz(action_target, action_name)
					else
						@null_action
					end
			end
			
			
			
			handler.set_finishing_callback do |action|
				# place the action on the undo stack so that it can be reversed if necessary
				# NOTE: need to use undo stack with the mouse actions as well
				
				# maybe wrap all Actions in a wrapper object,
				# that would provide the same interface as an Action
				# but then add the Action object to the undo stack when the Action completes?
				# If the action never properly completes (ie click -> drag transition)
				# then the Action object will never even be added to the stack.
				@action_history << action unless action.is_a? ThoughtTrace::Actions::NullAction
				@redo_stack.clear
			end
		end
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		handler = ThoughtTrace::Events::PressButton.new
		
		action_name = :undo
		button_id = Gosu::KbF7
		
		event = InputSystem::ButtonEvent.new(action_name, handler)
		event.bind_to keys:[button_id], modifiers:[]
		@buttons.register event
		
		handler.set_callback do
			unless @action_history.empty?
				prev = @action_history.pop
				
				prev.undo
				
				@redo_stack << prev
				
				print_history()
			end
			
			
			# this callback expects an action, so just give it a NullAction
			@null_action
		end
		
		
		
		handler.set_finishing_callback do |action|
			# do nothing here
			# do not want to store the NullAction, as it was just filler
		end
		
		
		
		
		
		handler = ThoughtTrace::Events::PressButton.new
		
		action_name = :redo
		button_id = Gosu::KbF8
		
		event = InputSystem::ButtonEvent.new(action_name, handler)
		event.bind_to keys:[button_id], modifiers:[]
		@buttons.register event
		
		handler.set_callback do
			unless @redo_stack.empty?
				prev = @redo_stack.pop
				
				prev.redo
				
				@action_history << prev
				
				print_history()
			end
			
			
			# this callback expects an action, so just give it a NullAction
			@null_action
		end
		
		
		
		handler.set_finishing_callback do |action|
			# do nothing here
			# do not want to store the NullAction, as it was just filler
		end
	end
	
	def button_down(id)
		[
			@buttons,
			# @mouse_input
		].each do |x|
			x.button_down(id)
		end
	end
	
	def update
		[
			@buttons,
			@text_input,
			@selection
			# @mouse_input
		].each do |x|
			x.update
		end
	end
	
	# draw things in world space
	def draw
		# NOTE: Input system is drawn after a flush of the draw queue, so UI will always be drawn on top of any element in the Space. It will never be occluded by the elements in the Space, not even the selection highlight ( that could actually be bad )
		
		@actions.each do |action|
			action.draw @mouse.position_in_space
		end
		
		@mouse_actions.each{ |x| x.draw  }
		
		@text_input.draw(@document.space)
		# @mouse_input.draw		
	end
	
	def button_up(id)
		[
			@buttons,
			# @mouse_input
		].each do |x|
			x.button_up(id)
		end
	end
	
	def on_shutdown
		@selection.on_shutdown
	end
	
	
	
	
	private
	
	def print_history
			puts "-----------------"
			puts "History"
		@action_history.each do |a|
			puts a.class
		end
			puts "-----------------"
	end
	
	
	def parse_cell_range(cell_range_string)
		c1,r1, c2,r2 = cell_range_string.scan(/(\D*)(\d*):(\D*)(\d*)/).first
		r1 = r1.to_i
		r2 = r2.to_i
		
		# p [c1, c2]
		return c1,r1, c2,r2
	end
	
	def load_mouse_binding_config(filepath, sheet_name)
		puts "loading mouse input bindings from .ods file"
		
		spreadsheet = Roo::Spreadsheet.open(filepath)
		
		# p spreadsheet.methods
		# p spreadsheet.sheets
		# p spreadsheet.sheet("Sheet4").methods.grep /each/
		# spreadsheet.sheet("Sheet4").each do |x|
		# 	p x.class
		# 	p x.size
		# 	p x
		# 	break
		# end
		
		
		
		
		data = Hash.new
		
		# start ods parsing to get input bindings
		cell_blocks = {
			:left_click   => "A6:E13",
			:right_click  => "G6:K13",
			:middle_click => "A20:E27"
		}
			# cell ranges given in in excel notation
		
		
		
		
		
		cell_blocks.each do |mouse_button, cell_range|
			# parse range into usable variables
			c1,r1, c2,r2 = parse_cell_range(cell_range)
			
			# iterate over range and get the data
			raw_data = 	(r1..r2).collect do |r|
			           		(c1..c2).collect do |c|
			           			# puts spreadsheet.sheet("Sheet4").cell(c,r)
			           			
			           			spreadsheet.sheet(sheet_name).cell(c,r)
			           		end
			           	end
			
			# parse strings, and store information in the "data" hash declared at the beginning
			formatted_data = 
				raw_data.collect do |binding, click_action, click_target, drag_action, drag_target|
					# convert accelerator names to list of symbols
					if binding == "NONE"
						binding = [] 
					else
						binding = binding.split('+').collect{|x| x.strip.to_sym }
					end
					
					# convert click / drag action names to symbols
					click_action, drag_action =
						[click_action, drag_action].collect do |input|
							input.tr(' ', '_').to_sym unless input.nil?
						end
					
					# format click / drag targets
					# (currently just leaving them as strings)
					# click_target, drag_target =
					# 	[click_target, drag_target].collect do |input|
					# 		input unless input.nil?
					# 	end
					
					
					
					
					
					p [binding, click_action, click_target, drag_action, drag_target]
					[binding, click_action, click_target, drag_action, drag_target]
				end
			
			
			# ===========
			# Actual data format specified here
			# ===========
			formatted_data.each do |binding, click_action, click_target, drag_action, drag_target|
				data[mouse_button] ||= Hash.new
				
				
				
				# NOTE: binding is always an array of symbols
				data[mouse_button][binding] = {
					:click => {
						:action => click_action,	:target => click_target
					},
					:drag => {
						:action => drag_action, 	:target => drag_target
					}
				}
				
			end
		end
		
		
		
		# input: pair = (button, [list, of accelerators])
		# note that is this is a scalar + Vec3, it's literally a Quaternion
		# 
		# output: pair = (action_name, target)
		
		
		
		
		# (button, [list, of accelerators])
		# (click / drag)
		# => (action_name, action_target)
		
		
		# test = [
		# 	[[nil, nil], [nil, nil]],
		# 	[[nil, nil], [nil, nil]],
		# 	[[nil, nil], [nil, nil]]
		# ]
		# x = [:left, :right, :middle]
		# y = # [accelerator list, in order]
		# xi = # index of 'mouse_button' in x
		# yi = # index of 'binding' in y
		# pos = xi*y.size + yi # all binds for one mb close together; big chucks for one mouse button
		
		# test[pos] # => [[nil, nil], [nil, nil]]
		
		
		
		# data.each do |k,v|
		# 	puts "#{k.inspect} => #{v.inspect}"
		# end
		
		return data
	end
end



end