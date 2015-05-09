module ThoughtTrace
	module Actions
		module EmptySpace
			module Actions


class SelectionAdd < Select
	initialize_with :space, :selection
	
	
	# called on first tick
	def press(point)
		super(point)
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		@set = super(point)
		@old_selection = @selection.all_items
		forward
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
		forward
	end
	
	
	
	private
	
	def forward
		@selection.union! @set
	end
end



end
end
end
end