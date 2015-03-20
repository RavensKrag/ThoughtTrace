module InputSystem



class MouseInputSystem
	# NOTE: a separate instance for this class is created for each mouse button
	# Turns press-hold-release event flow into the click-drag-release flow needed by mouse inputs
	
	
	
	# TODO: try to remove these array shortcuts. would be related to finding a better data structure for the input bindings, though
	CLICK = 0
	DRAG  = 1
	
	
	# TODO: create class that bundles the pieces of data that need to be sent to every Action. It's weird to have to "delegate" all these arguments through the chain of command like this.
	def initialize(space, mouse, action_factory,
		accelerator_collection, bindings)
		@mouse = mouse
		@space = space
		
		@action_factory = action_factory
		
		
		
		
		# TODO: figure out how to load this data from spatial ThoughtTrace file, instead of typing it out manually.
		# TODO: consider finding a better data structure for this data (maybe a tree?)
		
		@bindings = bindings
		
		
		
		@key_parser = accelerator_collection
		
		
		
		
		# @spatial_status = :on_object
		# @accelerators = [:shift]
		# @button_phase = CLICK
		@active_action = ThoughtTrace::Actions::NullAction.new "DUMMY NODE"
		@entity = nil
	end
	
	
	
	
	def draw
		@active_action.draw
	end
	
	
	
	# TODO: what happens when you hit left and right buttons down at the same time? both are Event-bound to fire things that eventually calls this part of the code, but this part of the code base assumes that the 4-key-phases will each only be called one at a time. THIS COULD CAUSE MASSIVE ERRORS. PLEASE RECTIFY IMMEDIATELY
	def press(event_name)
		# if there has been a mouse event
		
		
		# store accelerators from click, and always use those
		
		# this means that if you do
		# 'control+click -> release control -> drag'
		# you wind up with a control+drag
		# which may be undesirable
		# (I think I kinda like this "sloppy" evaluation though)
		@accelerators = @key_parser.active_accelerators
		
		
		
		
		point = @mouse.position_in_space
		@entity = @space.point_query_best point
		
		
		
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
		
		
		
		
		@current_phase = CLICK
		@active_action = parse_inputs(event_name, CLICK)
		@active_action.press(@mouse.position_in_space)
		
	end
	
	def hold(event_name)
		if @current_phase == CLICK
			# attempt to transition to the drag phase
			if mouse_exceeded_drag_threshold?
				# cancel the current action, (which should be a click action)
				# and load up the drag action (load with the same origin as the click action)
				
				@active_action.cancel
				
				@current_phase = DRAG
				@active_action = parse_inputs(event_name, DRAG)
				@active_action.press(@origin)
			end
		else
			# currently in the drag action
			
		end
		
		
		# manage the currently active action, if any
		@active_action.hold(@mouse.position_in_space)
	end
	
	def release(event_name)
		@active_action.release(@mouse.position_in_space)
		
		@active_action = ThoughtTrace::Actions::NullAction.new "DUMMY NODE"
		@entity = nil
	end
	
	def cancel(event_name)
		@active_action.cancel
		
		@active_action = ThoughtTrace::Actions::NullAction.new "DUMMY NODE"
		@entity = nil
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
	def mouse_exceeded_drag_threshold?
		point = @mouse.position_in_space
		
		displacement = point - @origin
		delta = displacement.length
		
		
		return delta > DRAG_DELTA_THRESHOLD
	end
end



end