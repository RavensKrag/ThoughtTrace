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
	
	def initialize(window, space, camera)
		@space = space
		@camera = camera
		
		
		# TODO: properly implement mouse.
		@mouse = InputSystem::Mouse.new window
		
		@selection = [] # TODO: create actual selection collection. Array is placeholder. May work, may not. Haven't actually thought about it at all.
		
		@text_input = ThoughtTrace::TextInput.new
		
		
		
		
		# manages many input events
		# input events correspond to button presses
		# those buttons can be keyboard keys, mouse buttons, or gamepad buttons
		@buttons = InputSystem::ButtonParser.new
		
		
		
		
		
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
		
		
		# action_flow = ThoughtTrace::ActionFlowController.new(@space, @selection, @stash)
		# # TODO: register action names in action flow controller
		# action_flow.bindings[categorization][phase] = action_name
		# # NOTE: There's no warning if you try to assign an action name to a phase that does not exist. This is really dangerous, and had me hunting bugs in a bunch of the wrong places.
		
		# 	event_name = :click
		# 	callbacks = InputSystem::MouseActionController.new @mouse, action_flow
		# event = InputSystem::ButtonEvent.new event_name, callbacks
		# event.bind_to keys:[Gosu::MsLeft], modifiers:[]
		
		# @buttons.register event
		
		
		
		
		action_flow = ThoughtTrace::ActionFlowController.new(@space, @selection, @text_input)
		callbacks = InputSystem::MouseActionController.new @mouse, action_flow
		
			event = InputSystem::ButtonEvent.new :click, callbacks
			event.bind_to keys:[Gosu::MsLeft], modifiers:[]
			
			action_flow.bindings[:existing][:click] = :edit
			action_flow.bindings[:existing][:drag] = :move
		
		@buttons.register event
		
		
		
		action_flow = ThoughtTrace::ActionFlowController.new(@space, @selection, @text_input)
		callbacks = InputSystem::MouseActionController.new @mouse, action_flow
		
			event = InputSystem::ButtonEvent.new :right_click, callbacks
			event.bind_to keys:[Gosu::MsRight], modifiers:[]
			
			action_flow.bindings[:existing][:drag] = :resize
		
		@buttons.register event
	end
	
	def button_down(id)
		@buttons.button_down(id)
	end
	
	def update
		@buttons.update
		@text_input.update
	end
	
	# draw things in world space
	def draw
		@text_input.draw
	end
	
	def button_up(id)
		@buttons.button_up(id)
	end
	
	def shutdown
		
	end
end



end