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
	
	def initialize(window, space, camera, clone_factory)
		@space = space
		@camera = camera
		@clone_factory = clone_factory
		
		
		# TODO: properly implement mouse.
		@mouse = InputSystem::Mouse.new window
		
		@selection = [] # TODO: create actual selection collection. Array is placeholder. May work, may not. Haven't actually thought about it at all.
		
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
		
		# action_flow = ThoughtTrace::ActionFlowController.new(
		# 				@space, @selection, @text_input, @clone_factory
		# 				)
		# callbacks = InputSystem::MouseActionController.new @mouse, action_flow
		
		# 	event = InputSystem::ButtonEvent.new :click, callbacks
		# 	event.bind_to keys:[Gosu::MsLeft], modifiers:[]
			
		# 	action_flow.bindings[:existing][:click] = :edit
		# 	action_flow.bindings[:existing][:drag] = :move
			
		# 	action_flow.bindings[:empty][:click] = :spawn_text
		# 	# action_flow.bindings[:empty][:drag] = 
		
		# @actions << action_flow
		# @buttons.register event
		
		
		
		
		
		
		
		
		
		
		# 		name = :shift
		# 		trigger = Trigger::Any.new Gosu::KbLeftShift, Gosu::KbRightShift
		# button = Button.new name, trigger
		
		
		
		
		
		
		
		
		
		
		
		
		
		# shift   =  (:shift, [Gosu::KbLeftShift, Gosu::KbRightShift])
		# control =  (:control, [Gosu::KbLeftControl, Gosu::KbRightControl])
		# alt     =  (:alt, [Gosu::KbLeftAlt, Gosu::KbRightAlt])

		# accelerators = [shift, control, alt]
		# accelerators.active_list 
		# 	accelerators.collect{|k| k.active? }
		
		
		
		
		# shift   = left_shift.active?    or  right_shift.active?
		# control = left_control.active?  or  right_control.active?
		# alt     = left_alt.active?      or  right_alt.active?
		
		# accelerators = {
		# 	:shift => shift,
		# 	:control => control,
		# 	:alt => alt
		# }
		
		
		
		# %w[left right].product(%w[shift control alt]).each do |side, symbol|
		# 	callbacks = ()
			
		# 	event_name = "#{side}_#{symbol}".to_sym
		# 	event = InputSystem::ButtonEvent.new event_name, callbacks
		# 	key_constant = Gosu.const_get "Kb#{side.capitalize}#{symbol.capitalize}"
		# 	event.bind_to keys:[key_constant], modifiers:[]
		# 	@buttons.register event
		# end
		
		
		
		
		
		
		
		
		
		# this could be useful in other parts of the input system
		# regardless, it's good do declare all bindings to lower-level input symbols at this level
		@accelerator_collection = InputSystem::AcceleratorCollection.new(
							[:shift,   Gosu::KbLeftShift,   Gosu::KbRightShift],
							[:control, Gosu::KbLeftControl, Gosu::KbRightControl],
							[:alt,     Gosu::KbLeftAlt,     Gosu::KbRightAlt]
						)
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		left_click_bindings  = {
			:on_object => {
				[]                        => [:edit, :select_sub_text],
				[:shift]                  => [nil, :resize],
				[:control]                => [:add_to_group, :constrain],
				[:alt]                    => [:split, nil],
				[:shift, :control]        => [nil, nil],
				[:shift, :alt]            => [nil, nil],
				[:control, :alt]          => [nil, nil],
				[:shift, :control, :alt]  => [nil, nil]
			},
			:empty_space => {
				[]                        => [nil, nil],
				[:shift]                  => [:spawn_text, nil],
				[:control]                => [:spawn_rect, nil],
				[:alt]                    => [:spawn_circle, nil],
				[:shift, :control]        => [nil, nil],
				[:shift, :alt]            => [nil, nil],
				[:control, :alt]          => [nil, nil],
				[:shift, :control, :alt]  => [nil, nil]
			}
		}
		
		
		
		right_click_bindings = {
			:on_object => {
				[]                        => [nil, :move],
				[:shift]                  => [nil, :duplicate],
				[:control]                => [:mark_as_query, :link],
				[:alt]                    => [:join, nil],
				[:shift, :control]        => [nil, :clone],
				[:shift, :alt]            => [nil, nil],
				[:control, :alt]          => [nil, nil],
				[:shift, :control, :alt]  => [nil, nil]
			},
			:empty_space => {
				[]                        => [nil, nil],
				[:shift]                  => [nil, nil],
				[:control]                => [:spawn_image, nil],
				[:alt]                    => [nil, nil],
				[:shift, :control]        => [nil, nil],
				[:shift, :alt]            => [nil, nil],
				[:control, :alt]          => [nil, nil],
				[:shift, :control, :alt]  => [nil, nil]
			}
		}
		
		
		
		
		# callbacks = InputSystem::MouseInputSystem.new(
		# 					@space, @mouse, @selection, @text_input, @clone_factory,
		# 					@accelerator_collection, mouse_button_mapping
		# 				)
		
		
		
		left_callbacks  = InputSystem::MouseInputSystem.new(
							@space, @mouse, @selection, @text_input, @clone_factory,
							@accelerator_collection, :left_click, left_click_bindings
						)
		
		right_callbacks = InputSystem::MouseInputSystem.new(
							@space, @mouse, @selection, @text_input, @clone_factory,
							@accelerator_collection, :right_click, right_click_bindings
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
		
		
		
		
		
		
		
		
		callbacks = ThoughtTrace::Events::PressEnter.new @space, @text_input, @clone_factory
		event = InputSystem::ButtonEvent.new :enter, callbacks
		
		event.bind_to keys:[Gosu::KbReturn], modifiers:[]
		
		@buttons.register event
		
	end
	
	def button_down(id)
		[
			@buttons,
			@accelerator_collection,
			# @mouse_input
		].each do |x|
			x.button_down(id)
		end
	end
	
	def update
		[
			@buttons,
			@text_input,
			# @mouse_input
		].each do |x|
			x.update
		end
	end
	
	# draw things in world space
	def draw
		@actions.each do |action|
			action.draw @mouse.position_in_space
		end
		
		@mouse_actions.each{ |x| x.draw  }
		
		@text_input.draw
		# @mouse_input.draw
	end
	
	def button_up(id)
		[
			@buttons,
			@accelerator_collection,
			# @mouse_input
		].each do |x|
			x.button_up(id)
		end
	end
	
	def shutdown
		
	end
end



end