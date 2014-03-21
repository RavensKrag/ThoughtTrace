# this file defines an function that returns a function
# the contents of this file can thus be executed,
# yielding a function
->(*args){
	# Split argument array into necessary variables
	# (argument array is the data loaded from the disk, packed into an array)
	font_name, x, y, height, string = args

	font = TextSpace::Font.new font_name # remove overlapping "font" to resolve
	text = TextSpace::Text.new font

	text.string = string

	text[:physics].body.p.x = x
	text[:physics].body.p.y = y

	text[:style][:height] = height
	text.resize! # this only needs to be run when loading
	# need to figure out how to resize automatically on font size change ASAP

	return text # need more unique identifier for space
	# may not actually need to expose this to the script
	# might want to just add the returned object to the space instead

}
