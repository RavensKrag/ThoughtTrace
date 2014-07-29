module ThoughtTrace
	module Style


# A type of list collection that allows for items to be moved up and down in priority at will
class List
	def initialize
		
	end
	
	
	def raise(index, by:1)
		
	end
	
	def lower(index, by:1)
		
	end
	
	
	
	
	# raise: move style as if it had been written one position EARLIER (lower cascade priority)
	# lower: move style as if it had been written one position LATER (higher cascade priority)
	# (ok, this interface is really really dumb.)
	# TODO: fix this interface. it's really really weird. feels like up is down or something
	# remember that this interface is tied to the traversal order of elements in the Cascade
	
	def raise(style, by:1)
		limit = 0
		
		# current position
		i = @cascade_stack.index style
		
		unless i == limit
		# destination position
		j = i - by
		j = limit if j < limit
		
			@cascade_stack.delete_at i
			@cascade_stack.insert j, style
		end
	end
	
	def lower(style, by:1)
		limit = @cascade_stack.size-1
		
		# current position
		i = @cascade_stack.index style
		
		unless i == limit
			# destination position
			j = i + by
			j = limit if j > limit
			
			@cascade_stack.delete_at i
			@cascade_stack.insert j, style
		end
	end
end



end
end