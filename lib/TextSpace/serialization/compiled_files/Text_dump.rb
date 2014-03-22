module TextSpace
	class Text
		class << self


def dump(text)
	font = TextSpace::Font.new font_name
	text = TextSpace::Text.new font
	
	text.string = string
	
	text[:physics].body.p.x = x
	text[:physics].body.p.y = y
	
	text[:style][:height] = height
	text.resize! # this only needs to be run when loading
	# need to figure out how to resize automatically on font size change ASAP.strip_comments.flip
	
	return font_name, x, y, height, string
end



end
end
end
