module ThoughtTrace
	class Entity
		module Actions


class Move < Action
	# called on first tick
	def setup(point)
		# mark the initial point for reference
		@origin = point
		
		# mark the initial point for reference
		@origin = point
		@start = @entity[:physics].body.p.clone
		
		return @start
	end
	
	# return two values: past and future used by Memento
	# called each tick
	def update(point)
		# move relative to the initial point
		displacement = point - @origin
		
		current = @entity[:physics].body.p = @start + displacement
		
		
		return current
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw(point)
		
	end
	
	
	
	# perform the transformation here
	# by encapsulating the transform in this object,
	# it becomes easy to redo / undo actions as necessary
	# (Consider better name. Current class name derives from a design pattern.)
	# (this class also has ideas from the command pattern, though)
	# TODO: consider that writing new versions of Memento may be unnecessary if the Memento always passes the @future / @past value(s) to #forward / #reverse. That's not currently what's happening necessarily, but that might be a good direction to go in.
	class Memento < Action::Memento
		# set future state
		def forward
			@entity[:physics].body.p = @future
		end
		
		# set past state
		def reverse
			@entity[:physics].body.p = @past
		end
	end
end



end
end
end