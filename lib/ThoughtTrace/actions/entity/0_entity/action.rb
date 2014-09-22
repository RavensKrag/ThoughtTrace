module ThoughtTrace
	class Entity
		module Actions


class Action < ThoughtTrace::Actions::BaseAction
	# NOTE: You might think that setting @entity in #press would remove the need to allocate a new ClickAndDragController object all the time. But that just means that the controller would have to be more aware of how Action works, which is not desirable.
	
	
	
	# continue to refrain from setting up initializer
	# allow each "concrete class" to set up it's initializer using #initialize_with
	# to specify what parameters it requires
	
	
	
	# inner API
	# separate from outer API so that you don't have to think about
	# creating or managing memos in child class implementation
		# called on first tick
		# returns value(s) passed to Memento as @initial
		def setup(point)
			
		end
		
		# called each tick
		# returns value(s) passed to Memento as @future
		def update(point)
			
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
	# (Consider better name. Current class name derives from a design pattern.)
	# (this class also has ideas from the command pattern, though)
	ParentMemento = self.superclass.const_get 'Memento'
	class Memento < ParentMemento
		# set future state
		def forward
			
		end
		
		# set past state
		def reverse
			
		end
	end
end



end
end
end