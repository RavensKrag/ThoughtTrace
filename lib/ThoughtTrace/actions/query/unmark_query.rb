module ThoughtTrace
	module Queries
		class Query
			module Actions


class ToggleQueryStatus < ThoughtTrace::Actions::OneShotAction
	# === unmark query ===
	initialize_with :entity
	
	# called on first tick
	def setup(point)
		
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@component = @entity[:query]
		@entity.delete_component :query
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@entity.add_component @component
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
end