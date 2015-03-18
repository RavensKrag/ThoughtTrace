module ThoughtTrace
	module Actions
		module EmptySpace
			module Actions


class NewSelection < ThoughtTrace::Actions::BaseAction
	initialize_with :action_factory, :selection
	
	
	# called on first tick
	def press(point)
		@select = @action_factory.create(nil, :select)
		@select.press(point)
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		@select.update(point)
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		@set = @select.release(point)
		@old_selection = @selection.collect{|x|  x }
		
		# selection should really be a Group, not just a Set
		# also, you can't just set the value by setting the variable: you need to move the data
		@selection.clear
		@set.each do |entity|
			@selection.add entity
		end
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@selection.clear
		@old_selection.each do |entity|
			@selection.add entity
		end
	end
	
	# changed my mind about undo-ing
	# apply the originally intended transformation to the data
	def redo
		@selection.clear
		@set.each do |entity|
			@selection.add entity
		end
	end
	
	
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		@select.update_visualization(point)
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		@select.draw
	end
end



end
end
end
end