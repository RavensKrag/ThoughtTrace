module ThoughtTrace


# controls click and drag flow
class ClickAndDragController
	def initialize(click_handler, drag_handler)
		# minimum distance for drag to be detected,
		# in whatever units are used for the Space
		@delta_threshold = 20
		
		
		# NOTE: may not be able to fire the click and drag events like this if the Actions can switch themselves out for other Actions, as was the case with ActionStash.
		# NOTE: handlers are currently just raw Actions, but you could weave another abstraction layer between ClickAndDragController and Action if it becomes necessary.
		@click = click_handler
		@drag = drag_handler
		
		@active = nil
	end
	
	def press(point)
		@origin = point
		
		@click.press(@origin)
		@active = @click
	end
	
	def hold(point)
		if @active == @click and delta_exceeded?(point)
			@click.cancel
			@drag.press(@origin)
			
			@active = @drag
		end
		
		@active.hold(point)
	end
	
	def release(point)
		@active.release(point)
	end
	
	def cancel
		@active.cancel
	end
	
	def draw
		# This should be the only phase where it is necessary to check if @active is set.
		# The other phases should either not be called when @active is unset, or will set @active.
		@active.draw if @active
		
		# TODO: visualize the drag threshold.
	end
	
	
	private
	
	def delta_exceeded?(point)
		displacement = point - @origin
		delta = displacement.length
		
		
		return delta > @delta_threshold
	end
end



end