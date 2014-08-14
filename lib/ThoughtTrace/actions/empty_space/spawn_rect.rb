module ThoughtTrace
	module Actions
		module EmptySpace


class SpawnRect < Actions::BaseAction
	# called on first tick
	def setup(point)
		rect = @clone_factory.make ThoughtTrace::Rectangle
		rect[:physics].body.p = point
		
		
		@space.entities.add rect
		
		
		return rect
	end
	
	# called each tick
	def update(point)
		
		return @space
	end
	
	# not often used, but you can define this callback if you need it
	# really, just added for completeness
	def cleanup(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw(point)
		
	end
	
	
	
	# perform the transformation here
	# by encapsulating the transform in this object,
	# it becomes easy to redo / undo actions as necessary
	ParentMemento = self.superclass.const_get 'Memento'
	class Memento < ParentMemento
		# set future state
		def forward
			
		end
		
		# set past state
		def reverse
			rect = @initial
			space = @future
			
			
			space.entities.delete rect
		end
	end
end


	
end
end
end