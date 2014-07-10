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
		style = cascade_stack.reverse_each.find{ |style| style[property] }
		return style[property]
	end
end