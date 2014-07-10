cascade_stack = [
	# highest priority
	Style.new()
	Style.new()
	Style.new()
	Style.new()
	Style.new()
	# lowest priority
]
# prioritized is #each iteration order
# high priority is reached before low priority in #each iteration
# ie, the cascade stack is sorted by priority, high to low



# search cascade order for a particular property
def foo(cascade_stack, property)
	# find the first style object in the cascade order which has the desired property
	style = cascade_stack.find{ |style| style[property] }
	return style[property]
end





cascade = CascadingStyleBlob.new
cascade.add "first", Style.new()
cascade.add "second", Style.new()
# items added later with have higher priority, like how CSS works


# move one Style object one position in the list
cascade.raise "second"
cascade.lower "first"





# Style object should have unique IDs
# those IDs should persists across sessions,
# they should be unique among all Style objects within the same space


# a style space holds all known Style objects
# many spaces can be initialized at one time,
# which can allow for namespacing
# (could alternatively use c-style prefix-namespacing on Style name if you would prefer)
# (though, I think it's always better to have an actual namespacing facility)

# Style objects are grouped into particular blobs.
# Blobs maintain cascade priority / searching for a particular property
# among multiple Style objects that are cascasding together to form a single, cohesive unit

