module InputSystem



class MouseInputSystem
	# TODO: try to remove these array shortcuts. would be related to finding a better data structure for the input bindings, though
	CLICK = 0
	DRAG  = 1
	
	
	# TODO: create class that bundles the pieces of data that need to be sent to every Action. It's weird to have to "delegate" all these arguments through the chain of command like this.
	def initialize(space, mouse, selection, text_input, clone_factory,
		accelerator_collection, mouse_button, bindings)
		# Necessary for this class only
		@mouse = mouse
		
		# things to send through to Action
		@space = space # @space is used at this level as well, to make the mouse queries
		
		@selection = selection
		@text_input = text_input
		@clone_factory = clone_factory
		
		
		
		# TODO: figure out how to load this data from spatial ThoughtTrace file, instead of typing it out manually.
		# TODO: consider finding a better data structure for this data (maybe a tree?)
		# TODO: consider that having right and left click buttons in the same place is weird and it should get split up? (but then what about the accelerator combinations aughhhh) hard to even consider that when this is the only key binding interface I really have available to me right now. Would be tedious to traverse a bunch of different structures at this point. Later, there would be abstraction, so that would be ok, but right now would be bad.
		
		
		@bindings = bindings
		
		
		
		@key_parser = accelerator_collection
		
		
		
		
		@mouse_button = mouse_button
		# @spatial_status = :on_object
		# @accelerators = [:shift]
		# @button_phase = CLICK
		@active_action = ThoughtTrace::Actions::NullAction.new "DUMMY NODE"
		@entity = nil
	end
	
	
	
	
	def draw
		@active_action.draw @mouse.position_in_space
	end
	
	
	
	# TODO: what happens when you hit left and right buttons down at the same time? both are Event-bound to fire things that eventually calls this part of the code, but this part of the code base assumes that the 4-key-phases will each only be called one at a time. THIS COULD CAUSE MASSIVE ERRORS. PLEASE RECTIFY IMMEDIATELY
	def press
		puts "start"
		
		
		# if there has been a mouse event
		@button_phase = CLICK
		
		@accelerators = @key_parser.active_accelerators
		
		
		
		
		point = @mouse.position_in_space
		@entity = @space.point_query_best point
		
		
		
		# store the initial point to be able to trigger mouse drag
		@origin = point
		
		
		
		@spatial_status = 
			if @entity
				:on_object
			else
				:empty_space
			end
		
		
		
		
		
		@active_action = parse_inputs()
		@active_action.press(@mouse.position_in_space)
		
	end
	
	def hold
		puts "hold"
		
		# while you're just checking for updates
		if mouse_exceeded_drag_threshold?()
			# if a drag has been triggered,
			# cancel the current action, (which should be a click action)
			# and load up the drag action (load with the same origin as the click action)
			@button_phase = DRAG
			
			
			@active_action.cancel
			
			@active_action = parse_inputs()
			@active_action.press(@origin)
		end
		
		
		# manage the currently active action, if any
		@active_action.hold(@mouse.position_in_space)
	end
	
	def release
		@active_action.release(@mouse.position_in_space)
		@entity = nil
	end
	
	def cancel
		puts "WOAH!"
		
		@active_action.cancel
	end
	
	
	
	
	private
	
	
	# given the current state of things, figure out what action you're firing
	# TODO: consider rename
	def parse_inputs
		possible_actions = @bindings[@spatial_status][@accelerators]
		action_name = possible_actions[@button_phase]
		
		
		
		warn "no action bound to #{@mouse_button} => [#{@spatial_status}, #{@accelerators}]" unless action_name
		
		
		
		
		place_to_look, target = 
			case @spatial_status
				when :on_object
					# assuming we have found an existing Entity
					# but that it has no special characteristics
					
					[@entity.class, @entity]
					
				when :empty_space
					# space is empty at desired point
					
					# no target, because most actions in empty space create new things
					# the target supposed to be a thing which already exists
					# but that doesn't make sense for an action that creates something new
					[ThoughtTrace::Actions::EmptySpace, nil]
			end
		
		
		
		
		
		standard_args = [@space, @selection, @text_input, @clone_factory]
		
		action = place_to_look.action_get(action_name).new(*standard_args,  target)
		
		# TODO: make easy way to check if Action is a the null object for that type of action. Sorta like how you can call #nil? on an object to check if it is nil or not
		if action_name and action.is_a? ThoughtTrace::Actions::NullAction
			warn "#{place_to_look.inspect} does not define action '#{action_name}'"
		end
		
		
		
		# p action
		
		return action
	end
	
	DELTA_THRESHOLD = 20
	def mouse_exceeded_drag_threshold?
		point = @mouse.position_in_space
		
		displacement = point - @origin
		delta = displacement.length
		
		
		return delta > DELTA_THRESHOLD
	end
	
	
	
	
	def cache_data(point)
		
	end
end



end