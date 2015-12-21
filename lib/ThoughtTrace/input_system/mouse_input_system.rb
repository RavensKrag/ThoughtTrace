module InputSystem



class MouseInputSystem
	# NOTE: a separate instance for this class is created for each mouse button
	# Turns press-hold-release event flow into the click-drag-release flow needed by mouse inputs
	
	attr_reader :current_phase
	
	# TODO: create class that bundles the pieces of data that need to be sent to every Action. It's weird to have to "delegate" all these arguments through the chain of command like this.
	def initialize(mouse)
		@mouse = mouse
		
		@dummy_action = ThoughtTrace::Actions::NullAction.new "DUMMY NODE"
		@active_action = @dummy_action
		
		@current_phase = :idle
	end
	
	
	
	
	def draw
		@active_action.draw
	end
	
	
	
	# TODO: what happens when you hit left and right buttons down at the same time? both are Event-bound to fire things that eventually calls this part of the code, but this part of the code base assumes that the 4-key-phases will each only be called one at a time. THIS COULD CAUSE MASSIVE ERRORS. PLEASE RECTIFY IMMEDIATELY
	def press
		@current_phase = :click
		
		
		# if there has been a mouse event
		point = @mouse_position_callback.call(@current_phase)
		
		
		# store the initial point to be able to trigger mouse drag
		@origin = point
		
		
		@active_action = @parse_input_callback.call(:click, point)
		@active_action.press(point)
		
	end
	
	def hold
		point = @mouse_position_callback.call(@current_phase)
		
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
		point = @mouse_position_callback.call(@current_phase)
		
		@active_action.release(point)
		
		done = @active_action
		@finishing_callback.call(done)
		
		@active_action = @dummy_action
		@current_phase = :idle
	end
	
	def cancel
		@active_action.cancel
		
		@active_action = @dummy_action
		@current_phase = :idle
	end
	
	
	
	
	def parse_callback(&block)
		@parse_input_callback = block
	end
	
	def finishing_callback(&block)
		@finishing_callback = block
	end
	
	def mouse_position_callback(&block)
		@mouse_position_callback = block
	end
	
	
	
	
	private
	
	
	
	DRAG_DELTA_THRESHOLD = 20
	def mouse_exceeded_drag_threshold?(point)
		displacement = point - @origin
		delta = displacement.length
		
		
		return delta > DRAG_DELTA_THRESHOLD
	end
end



end