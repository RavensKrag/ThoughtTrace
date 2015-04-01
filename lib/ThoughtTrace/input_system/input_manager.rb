module ThoughtTrace


# Controls overall execution flow for all input systems.
# Like a main method for the entire input system.
# 
# As it is a "main", this class is more a portion of ThoughtTrace proper,
# rather than something than can be externalized.
# This is reflected in the module chosen to hold this class.
class InputManager
	# TODO: control mouseover effects from this class as well
	
	attr_reader :mouse, :buttons
	
	def initialize(window, document)
		# TODO: should probably just pass the window and the document
		# TODO: take note of what things would need to be updated if the bound document were to shift
		@document = document
		
		
		
		# TODO: properly implement mouse.
		@mouse = InputSystem::Mouse.new window, @document.camera
		
		# TODO: figure out if the selection Group needs to be added to the Space or something. How are Groups being tracked?
		@selection = ThoughtTrace::Groups::Group.new
		
		@text_input = ThoughtTrace::TextInput.new
		
		
		
		
		# manages many input events
		# input events correspond to button presses
		# those buttons can be keyboard keys, mouse buttons, or gamepad buttons
		@buttons = InputSystem::ButtonParser.new
		
		
		
		
		# hold actions flow controllers, so that input manager can direct action UI drawing
		# need to draw actions so that they can show polymorphic interface information
		# NOTE: storing actions this way means that the button parser doesn't have to know anything about the input system.
		@actions = Array.new
		
		# NOTE: Action names and Event names may not necessarily have the same requirements.
			# Action names
				# Control what sort of action will be fired
				# Like methods, specifics are resolved with polymorphism
			# Event names
				# unique ID for this specific Event
				# must be distinct among keyboard, mouse, joystick etc events
				# each Event is one combination of (name, binding, callback)
				# thus, it is possible for many events to trigger one Action
				# because you want multiple bindings on one Action
				# (thing mouse bindings vs keyboard, rather than multiple keyboard shortcuts)
		
		
		
		# TODO: clean up mouse action flow classes. Many of them are no longer needed.
		# TODO: clean up button input system to synergize with new accelerator system
		
		
		
		# TODO: consider moving the action factory into the Document, if it would somehow make document switching easier to just bind the action factory present inside each document, instead of having to re-init the factories. But maybe that structure just doesn't work for some reason.
		action_factory = InputSystem::ActionFactory.new(
							@selection,
							
							:selection => @selection,
							:text_input => @text_input,
							
							:space => @document.space,
							:clone_factory => @document.prototypes,
							:styles => @document.named_styles
						)
		
		
		
		
		
		
		
		
		
		
		# this could be useful in other parts of the input system
		# regardless, it's good do declare all bindings to lower-level input symbols at this level
		@accelerator_parser = InputSystem::AcceleratorParser.new(
							window,
							:shift   => [Gosu::KbLeftShift,   Gosu::KbRightShift],
							:control => [Gosu::KbLeftControl, Gosu::KbRightControl],
							:alt     => [Gosu::KbLeftAlt,     Gosu::KbRightAlt]
						)
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		# control: constraint mode ( drag for constraint, click for query? kinda makes sense )
 		# alt:     selection mode  ( selection and groups are pretty much the same thing )
 		# shift:   extra modifier - mode dependent
 		
 		# control + alt = query? (queries are kinda like constraints, and they select things...)
 		
 		
 		# NOTE: need Entity type 'image'
 		# NOTE: spawning new Entities has been removed from input bindings. Should use duplication of existing things, or drag in items from the prototype list.
 		# TODO: implement prototype list UI system.
 		
 		# NOTE: it's not really 'empty space' binding as much as it is 'no entity target' binding. Should probably update the system to reflect that. Shouldn't have to declare things that require no target twice.
 		
 		left_click_bindings  = {
			:on_object => {
				[]                        => [:place_text_caret,       :edit              ],
				[:shift]                  => [:spawn_text,             :resize            ],
				[:control]                => [:toggle_query_status,    :constrain         ],
				[:alt]                    => [:select_single,          :new_selection     ],
				[:shift, :control]        => [nil,                     nil],
				[:shift, :alt]            => [:single_select_add,      :selection_add     ],
				[:control, :alt]          => [:single_select_subtract, :selection_subtract],
				[:shift, :control, :alt]  => [nil,                     nil]
			},
			:empty_space => {
				[]                        => [nil,                     nil                 ],
				[:shift]                  => [:spawn_text,             nil                 ],
				[:control]                => [nil,                     nil                 ],
				[:alt]                    => [nil,                     :new_selection      ],
				[:shift, :control]        => [nil,                     nil                 ],
				[:shift, :alt]            => [nil,                     :selection_add      ],
				[:control, :alt]          => [nil,                     :selection_subtract ],
				[:shift, :control, :alt]  => [nil,                     nil                 ]
			}
		}
		
		
		
		right_click_bindings = {
			:on_object => {
				[]                        => [nil, :move],
				[:shift]                  => [nil, :duplicate],
				[:control]                => [nil, :clone],
				[:alt]                    => [:join, nil],
				[:shift, :control]        => [nil, :mirror],
				[:shift, :alt]            => [nil, nil],
				[:control, :alt]          => [nil, nil],
				[:shift, :control, :alt]  => [nil, nil]
			},
			:empty_space => {
				[]                        => [nil, nil],
				[:shift]                  => [nil, nil],
				[:control]                => [nil, nil],
				[:alt]                    => [nil, nil],
				[:shift, :control]        => [nil, nil],
				[:shift, :alt]            => [nil, nil],
				[:control, :alt]          => [nil, nil],
				[:shift, :control, :alt]  => [nil, nil]
			}
		}
		
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
		
		mouse_wheel_actions = {
				[]                        => [:zoom],
				[:shift]                  => [:render_layer],
				[:control]                => [:abstraction_layer],
				[:alt]                    => [nil],
				[:shift, :control]        => [nil],
				[:shift, :alt]            => [nil],
				[:control, :alt]          => [nil],
				[:shift, :control, :alt]  => [nil]
		}
		
		
		
		
		left_callbacks  = InputSystem::MouseInputSystem.new(
							@document.space, @mouse, action_factory,
							@accelerator_parser, left_click_bindings
						)
		
		right_callbacks = InputSystem::MouseInputSystem.new(
							@document.space, @mouse, action_factory,
							@accelerator_parser, right_click_bindings
						)
		
		
		
		event = InputSystem::ButtonEvent.new :left_click, left_callbacks
		event.bind_to keys:[Gosu::MsLeft], modifiers:[]
		@buttons.register event
		
		
		
		event = InputSystem::ButtonEvent.new :right_click, right_callbacks
		event.bind_to keys:[Gosu::MsRight], modifiers:[]
		@buttons.register event
 		
 		
 		# events weren't DESIGNED this way,
		# but turns out that you only need to press AT LEAST what's specified to fire an event
		# thus, "click + control" will trigger events bound to "click + [NO MODIFIERS]"
		
		# should consider splitting out modifiers into a separate system
		# separate from the core press-hold-release and raw button abstraction logic
 		
		
		
		
		@mouse_actions = [left_callbacks, right_callbacks]
		
		
		
		
		
		
		
		
		
		
		# camera control
		callbacks = InputSystem::CameraController.new @mouse, @document.camera, action_factory
		event = InputSystem::ButtonEvent.new :pan_camera, callbacks
		event.bind_to keys:[Gosu::MsMiddle], modifiers:[]
		@buttons.register event
		
		
		
		
		
		
		
		
		
		callbacks = ThoughtTrace::Events::PressEnter.new @document.space, @text_input, @document.prototypes
		event = InputSystem::ButtonEvent.new :enter, callbacks
		
		event.bind_to keys:[Gosu::KbReturn], modifiers:[]
		
		@buttons.register event
		
		
		
		callbacks = ThoughtTrace::Events::LinkStyles.new @selection, action_factory
		event = InputSystem::ButtonEvent.new :link_styles, callbacks
		
		event.bind_to keys:[Gosu::KbF8], modifiers:[]
		
		@buttons.register event
		
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
		
		@text_input.draw
		# @mouse_input.draw
		
		@selection.draw(@document.space) # selection is a Group
	end
	
	def button_up(id)
		[
			@buttons,
			# @mouse_input
		].each do |x|
			x.button_up(id)
		end
	end
	
	def shutdown
		
	end
end



end