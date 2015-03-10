module ThoughtTrace
	module Actions
		module EmptySpace
			module Actions


class SpawnText < ThoughtTrace::Actions::OneShotAction
	initialize_with :clone_factory, :space, :text_input
	
	# called on first tick
	def setup(point)
		# TODO: new Text should have the same size, font, etc as the last Text object accessed. ie, user should be able to create multiple similar Text objects in succession, without having to rely on the default font
		@text = @clone_factory.make ThoughtTrace::Text
		@text[:physics].body.p = point
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@space.entities.add @text
		@text_input.add @text, 0
		@already_added = true
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@space.entities.delete @text
		@text_input.clear
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