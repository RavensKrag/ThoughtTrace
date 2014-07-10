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
	
	
	# TODO: need a way to re-arrange the cascade order
	
	def raise(style)
		i = @cascade_stack.index style
		unless i == 0 # don't want to fall off the... front (that's odd to say)
			@cascade_stack.delete_at i
			@cascade_stack.insert i-1, style
		end
	end
	
	def lower(style)
		i = @cascade_stack.index style
		unless i == @cascade_stack.size-1 # don't want to fall off the end
			@cascade_stack.delete_at i
			@cascade_stack.insert i+1, style
		end
	end
end