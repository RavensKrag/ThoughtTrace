module ThoughtTrace
	class Queries
		module Actions


class UnmarkQuery < ThoughtTrace::Actions::BaseAction
	# called on first tick
	def setup(point)
		unmark_entity(@target)
		
		return nil
	end
	
	# called each tick
	def update(point)
		
		return nil
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
			
		end
	end
end



end
end
end