
# pretty much don't need this any more,
# considering how little boilerplate is required for new Action format

module ThoughtTrace
	class Entity
		module Actions


class Foo < Entity::Actions::Action
	initialize_with :foo, :baz, :bar
	# metaprogrraming method
		# defines #initialize to set specified values
		# defines list of symbol names, so Action creation system knows what variables to pass in
	
	
	# called on first tick
	def press(point)
		
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		
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
end



end
end
end