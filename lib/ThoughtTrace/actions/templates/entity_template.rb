module ThoughtTrace
	class Entity
		module Actions


class Foo < Entity::Actions::Action
	# called on first tick
	def setup(point)
		@original = nil
		return @original
	end
	
	# return two values: past and future used by Memento
	# called each tick
	def update(point)
		
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
	
	
	
	# perform the transformation here
	# by encapsulating the transform in this object,
	# it becomes easy to redo / undo actions as necessary
	ParentMemento = self.superclass.const_get 'Memento'
	class Memento < ParentMemento
		# set future state
		def forward
			@entity.baz(@future)
		end
		
		# set past state
		def reverse
			@entity.baz(@initial)
		end
	end
end



end
end
end