
# pretty much don't need this any more,
# considering how little boilerplate is required for new Action format

module ThoughtTrace
	class Entity
		module Actions


class Duplicate < Entity::Actions::Action
	initialize_with :entity, :space
	# BUG: once duplicate is used, neither the original entity nor the clone can be moved until restart.
		# once I properly defined @space.entities.delete to remove shapes / bodies when items are removed from the list, then this bug seems to have cleared up. That's very bizarre.
	
	
	# called on first tick
	def press(point)
		@clone = @entity.clone
		# TODO: probably want to copy Component properties of cloned objects as well
		
		@move_action = ThoughtTrace::Entity::Actions::Move.new(@clone)
		@move_action.press(point)
		
		
		@already_added = false
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		@move_action.update(point)
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		unless @already_added
			@space.entities.add @clone
			@already_added = true
		end
		
		@move_action.apply
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@space.entities.delete @clone
		
		@already_added = false
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		@move_action.update_visualization(point)
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		
	end
end



end
end
end