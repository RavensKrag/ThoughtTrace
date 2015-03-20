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
	
	# changed my mind about undo-ing
	# apply the originally intended transformation to the data
	def redo
		@selection.clear
		super
	end
end



end
end
end
end