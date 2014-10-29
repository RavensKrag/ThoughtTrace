module ThoughtTrace
	class Entity
		module Actions


class ToggleQueryStatus < Entity::Actions::Action
	initialize_with :entity, :styles
	
	# called on first tick
	def setup(point)
		# === mark query ===
		
		# the type of query object to be used will very, depending on what you want to do
		# you could ever re-bind the Query object inside the component at runtime if you like
		query = ThoughtTrace::Queries::Query.new
			# queries require access to the space,
			# but this will provided as an argument to the Query callbacks, rather than on init
		
		
		# the component will always have the same structure
		component = ThoughtTrace::Components::Query.new(@styles["Shared Query Style"], query)
		@entity.add_component component
		
		
		
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