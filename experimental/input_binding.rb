class InputManager
	def initialize
		action_flow = ThoughtTrace::ActionFlowController.new(
						@space, @selection, @text_input, @clone_factory
						)
		callbacks = InputSystem::MouseActionController.new @mouse, action_flow
		
			event = InputSystem::ButtonEvent.new :click, callbacks
			event.bind_to keys:[Gosu::MsLeft], modifiers:[]
			
			action_flow.bindings[:existing][:click] = :edit
			action_flow.bindings[:existing][:drag] = :move
			
			action_flow.bindings[:empty][:click] = :spawn_text
			# action_flow.bindings[:empty][:drag] = 
		
		@actions << action_flow
		@buttons.register event
		
		
		
		action_flow = ThoughtTrace::ActionFlowController.new(
						@space, @selection, @text_input, @clone_factory
						)
		callbacks = InputSystem::MouseActionController.new @mouse, action_flow
		
			event = InputSystem::ButtonEvent.new :right_click, callbacks
			event.bind_to keys:[Gosu::MsRight], modifiers:[]
			
			action_flow.bindings[:existing][:drag] = :resize
		
		@actions << action_flow
		@buttons.register event
		
		
		
		
		
		callbacks = ThoughtTrace::Events::PressEnter.new @space, @text_input, @clone_factory
		event = InputSystem::ButtonEvent.new :enter, callbacks
		
		event.bind_to keys:[Gosu::KbReturn], modifiers:[]
		
		@buttons.register event
		
		
		
		
		
		
		
		
		# allow for all combinations, if possible
			# standard: movement
			# control:     precision   (insert)
			# shift        larger      (duplicate)
			# alt:         strange     (linked data)  
		
		
		movement            keys: [left click]
			= standard        modifiers: [none]
			        move
			- special         modifiers: [control]
			        insert
			- special         modifiers: [shift]
			        clone?
			- special         modifiers: [shift alt]
			        linked clone
			- special         modifiers: [alt]
			        linked duplication?
		
		
		
		
		spawn
			text           click
			rect           drag
			circle         control drag (corner to corner (like box select))
			text box       shift drag  (drag sets radius)
			
			
			image          drop image into application
		
		
		
		
		pallets   # contolled by a fixed set of buttons in a row
			F-Keys         [Gosu::KbF1..Gosu::KbF12]
			# this range doesn't actually work (at least not as expected)
			
			
			
			
			BUTTON
			layers?
				# not sure if this should be a thing or not
			
			
			
			CONTROL
			color
				# key applies current color
				# (to what? hovered element? selected? most entire selection)
				1        color a
				2        color b
				3        color c
				4        color d
				5        color e
				6        color f
				7        color g
				8        color h
				9        color i
				10       color j
				11       color k
				12       color l
			
			
			SHIFT
			camera layer
				# toggle layer visibility when the corresponding input is activated
				1    constraints      keys:[Gosu::KbF1], modifiers:[]
				2    queries          keys:[Gosu::KbF2], modifiers:[]
				3    entities         keys:[Gosu::KbF3], modifiers:[]
				4    groups           keys:[Gosu::KbF4], modifiers:[]
				5    ui entities      keys:[Gosu::KbF5], modifiers:[]
				
	end
	
	
	
	
	def button_down(id)
		
	end
	
	def update
		
	end
	
	def button_up(id)
		
	end
end