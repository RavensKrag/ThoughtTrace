module InputSystem



class MouseInputSystem
	# NOTE: a separate instance for this class is created for each mouse button
	# Turns press-hold-release event flow into the click-drag-release flow needed by mouse inputs
	
	attr_reader :current_phase
	
	# TODO: create class that bundles the pieces of data that need to be sent to every Action. It's weird to have to "delegate" all these arguments through the chain of command like this.
	def initialize(mouse)
		@mouse = mouse
		
		# @spatial_status = :on_object
		# @accelerators = [:shift]
		# @button_phase = CLICK
		@dummy_action = ThoughtTrace::Actions::NullAction.new "DUMMY NODE"
		@active_action = @dummy_action
		@entity = nil
	end
	
	
	
	
	def draw
		@active_action.draw
	end
	
	
	
	# TODO: what happens when you hit left and right buttons down at the same time? both are Event-bound to fire things that eventually calls this part of the code, but this part of the code base assumes that the 4-key-phases will each only be called one at a time. THIS COULD CAUSE MASSIVE ERRORS. PLEASE RECTIFY IMMEDIATELY
	def press
		# if there has been a mouse event
		
		
		# store accelerators from click, and always use those
		
		# this means that if you do
		# 'control+click -> release control -> drag'
		# you wind up with a control+drag
		# which may be undesirable
		# (I think I kinda like this "sloppy" evaluation though)
		
		# @accelerators = @key_parser.active_accelerators
		
		
		
		
		point = @mouse.position_in_space
		# @entity = @space.point_query_best point
		
		
		
		# store the initial point to be able to trigger mouse drag
		@origin = point
		
		
		# only set this in #press
		# don't want target to change in the middle of the input
		@spatial_status = 
			if @entity
				:on_object
			else
				:empty_space
			end
		
		
		
		
		@current_phase = :click
		@active_action = @parse_input_callback.call(:click, point)
		@active_action.press(point)
		
	end
	
	def hold
		point = @mouse.position_in_space
		
		if @current_phase == :click
			# attempt to transition to the drag phase
			if mouse_exceeded_drag_threshold?(point)
				# cancel the current action, (which should be a click action)
				# and load up the drag action (load with the same origin as the click action)
				
				@active_action.cancel
				
				@current_phase = :drag
				@active_action = @parse_input_callback.call(:drag, @origin)
				@active_action.press(@origin)
			end
		else
			# currently in the drag action
			
		end
		
		
		# manage the currently active action, if any
		@active_action.hold(point)
	end
	
	def release
		point = @mouse.position_in_space
		
		@active_action.release(point)
		
		@active_action = @dummy_action
		@current_phase = :idle
	end
	
	def cancel
		point = @mouse.position_in_space
		
		@active_action.cancel
		
		@active_action = @dummy_action
		@current_phase = :idle
	end
	
	def parse_callback(&block)
		@parse_input_callback = block
	end
	
	
	
	
	private
	
	
	# given the current state of things, figure out what action you're firing
	# TODO: consider rename
	# TODO: consider trying to reduce the amount of stored state.
	def parse_inputs(event_name, button_phase)
		possible_actions = @bindings[@spatial_status][@accelerators]
		action_name = possible_actions[button_phase]
		
		
		
		warn "no action bound to #{event_name} => [#{@spatial_status}, #{@accelerators}]" unless action_name
		
		
		# special exception to let 'spawn text' happen anywhere,
		# even though it's defined as an 'empty space' action
		# because it can't have a defined target.
		target = @entity
		target = nil if action_name == :spawn_text
		
		# NOTE: new action factory does not require the @spatial_status. may want to remove that concept from this part of the code as well.
		action = @action_factory.create(target, action_name)
		
		
		return action
	end
	
	DRAG_DELTA_THRESHOLD = 20
	def mouse_exceeded_drag_threshold?(point)
		displacement = point - @origin
		delta = displacement.length
		
		
		return delta > DRAG_DELTA_THRESHOLD
	end
end



end