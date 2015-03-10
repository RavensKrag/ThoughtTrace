module ThoughtTrace
	module Actions
		module EmptySpace
			module Actions


class SpawnRect < ThoughtTrace::Actions::OneShotAction
	initialize_with :clone_factory, :space
	
	# called on first tick
	def setup(point)
		@rect = @clone_factory.make ThoughtTrace::Rectangle
		@rect[:physics].body.p = point
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@space.entities.add @rect
		@already_added = true
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@space.entities.delete @rect
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