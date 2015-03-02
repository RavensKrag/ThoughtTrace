module ThoughtTrace
	module Actions
		module EmptySpace
			module Actions


class SpawnCircle < ThoughtTrace::Actions::BaseAction
	initialize_with :clone_factory, :space
	
	# called on first tick
	def setup(point)
		# TODO: new Text should have the same size, font, etc as the last Text object accessed. ie, user should be able to create multiple similar Text objects in succession, without having to rely on the default font
		circle = @clone_factory.make ThoughtTrace::Circle
		circle[:physics].body.p = point
		
		
		@space.entities.add circle
		
		
		return circle
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
			circle = @initial
			space = @future
			
			
			space.entities.delete circle
		end
	end
end


	
end
end
end
end