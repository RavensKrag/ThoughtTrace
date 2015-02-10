module ThoughtTrace
	class Entity
		module Actions


class Move < Entity::Actions::Action
	initialize_with :entity
	
	# called on first tick
	def setup(point)
		# mark the initial point for reference
		@origin = point
		@start = @entity[:physics].body.p.clone
		
		return @start
	end
	
	# called each tick
	def update(point)
		# move relative to the initial point
		current = @entity[:physics].body.p = @start + movement_delta(point)
		
		
		return current
	end
	
	# not often used, but you can define this callback if you need it
	# really, just added for completeness
	def cleanup(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw(point)
		
	end
	
	
	
	private
	
	def movement_delta(point)
		return point - @origin
	end
	
	public
	
	
	
	
	# perform the transformation here
	# by encapsulating the transform in this object,
	# it becomes easy to redo / undo actions as necessary
	ParentMemento = self.superclass.const_get 'Memento'
	class Memento < ParentMemento
		# set future state
		def forward
			@entity[:physics].body.p = @future
		end
		
		# set past state
		def reverse
			@entity[:physics].body.p = @initial
		end
	end
end



end
end
end