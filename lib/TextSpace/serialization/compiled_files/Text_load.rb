module TextSpace
	class Text


def load(font_name, x, y, height, string)
	font = TextSpace::Font.new font_name
	text = TextSpace::Text.new font
	
	text.string = string
	
	text[:physics].body.p.x = x
	text[:physics].body.p.y = y
	
	text[:style][:height] = height
	text.resize! # this only needs to be run when loading
	# need to figure out how to resize automatically on font size change ASAP
	
	return text
end



end
end
