module ThoughtTrace
	class Entity
		module Actions


class ToggleQueryStatus < ThoughtTrace::Actions::OneShotAction
	# === mark query ===
	initialize_with :entity, :styles
	
	# called on first tick
	def apply(point)
		# the type of query object to be used will very, depending on what you want to do
		# you could ever re-bind the Query object inside the component at runtime if you like
		query = ThoughtTrace::Queries::Query.new
			# queries require access to the space,
			# but this will provided as an argument to the Query callbacks, rather than on init
		
		
		# the component will always have the same structure
		@component = ThoughtTrace::Components::Query.new(@styles["Shared Query Style"], query)
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@entity.add_component @component			
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@entity.delete_component :query
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		
	end
end



end
end
end