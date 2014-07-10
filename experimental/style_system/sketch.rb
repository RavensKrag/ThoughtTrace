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


cascade = CascadingStyleBlob.new
cascade.add "first", Style.new()
cascade.add "second", Style.new()
# items added later with have higher priority, like how CSS works


# move one Style object one position in the list
cascade.raise "second"
cascade.lower "first"