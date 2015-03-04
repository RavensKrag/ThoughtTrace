module ThoughtTrace
	class Entity
		module Actions


class Move < Entity::Actions::Action
	initialize_with :entity
	
	# called on first tick
	def press(point)
		# mark the initial point for reference
		@origin = point
		@start = @target[:physics].body.p.clone
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		# move relative to the initial point
		@destination = @start + movement_delta(point)
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@target[:physics].body.p = @destination
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@target[:physics].body.p = @start
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		
	end
	
	
	
	private
	
	def movement_delta(point)
		return point - @origin
	end
end



end
end
end