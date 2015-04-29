module ThoughtTrace
	class Text < Rectangle
		module Actions


class Resize < Rectangle::Actions::Resize
	MARGIN = 50
	MINIMUM_FONT_HEIGHT = 10
	
	initialize_with :entity
	
	# called on first tick
	def press(point)
		super(point) # sets @origin and @direction
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		super(point)
		
		# simple ratio solution courtesy of this link
		# http://tech.pro/tutorial/691/csharp-tutorial-font-scaling
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		super()
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		super()
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		super(point)
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		# super(point)
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		# NOTE: consider adjusting margins for Text resize, such that the bottom margin matches up with the baseline of the text.
		# super()
	end
end



end
end
end