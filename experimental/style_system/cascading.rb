# handles style cascading, but not the actual style property management

class CascadingStyleBlob
	def initialize
		@cascade_stack = Array.new
	end
	
	# add a new style to the cascade
	# style elements added later have priority over ones that came before
	# (just like )
	def add(style)
		@cascade_stack << style
	end
	
	# search cascade order for a particular property
	def [](property)
		# find the first style object in the cascade order which has the desired property
		style = @cascade_stack.reverse_each.find{ |style| style[property] }
		return style[property]
	end
	
	
	# raise: move style as if it had been written one position EARLIER (lower cascade priority)
	# lower: move style as if it had been written one position LATER (higher cascade priority)
	# (ok, this interface is really really dumb.)
	
	def raise(style, times=1)
		# current position
		i = @cascade_stack.index style
		
		# destination position
		j = i - times
		limit = 0
		j = limit if j < limit
		
		unless j == i
			@cascade_stack.delete_at i
			@cascade_stack.insert j, style
		end
	end
	
	def lower(style, times=1)
		# current position
		i = @cascade_stack.index style
		
		# destination position
		j = i + times
		limit = @cascade_stack.size-1
		j = limit if j > limit
		
		unless j == i
			@cascade_stack.delete_at i
			@cascade_stack.insert j, style
		end
	end
end