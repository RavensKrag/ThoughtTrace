module ThoughtTrace
	class Entity
		module Actions


class MarkAsQuery < Entity::Actions::Action
	# called on first tick
	def setup(point)
		query = ThoughtTrace::Queries::Query.new @space
		query.bind @entity
		
		@space.queries.add query
		
		return query
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
			query = @initial
			space = @future
			
			query.unbind
			space.queries.delete query
		end
	end
end



end
end
end