module ThoughtTrace
	module Constraints


class Marker
	module Actions


class Move < ThoughtTrace::Entity::Actions::Move
	@type_list = Entity::Actions::Move.argument_type_list
	# by creating a child class of an action, you inherit the initializer, but not the type list
	
	initialize_with :entity, :space
	
	
	# called on first tick
	def press(point)
		super(point)
		marker = @entity
		marker.unbind
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		super(point)
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		super()
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		marker = @entity
		target = @space.point_query_best(point, exclude:[marker])
		if target
			marker.bind_to target
		end
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		super()
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
