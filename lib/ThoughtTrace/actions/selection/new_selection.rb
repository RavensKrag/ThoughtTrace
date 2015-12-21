module ThoughtTrace
	module Actions
		module EmptySpace
			module Actions


class NewSelection < SelectionAdd
	initialize_with :space, :selection
	
	
	# called on first tick
	def press(point)
		super(point)
		
		@selection.clear
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		super(point)
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		super()
	end
	
	# changed my mind about undo-ing
	# apply the originally intended transformation to the data
	def redo
		@selection.clear
		
		super()
	end
	
	
	
	private
	
	def forward
		super()
	end
end



end
end
end
end