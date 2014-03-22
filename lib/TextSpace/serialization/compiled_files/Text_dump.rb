class Text
	class << self


def dump(text)
	# examining this object: text


	text.resize!
	height = text[:style][:height]

	y = text[:physics].body.p.y
	x = text[:physics].body.p.x

	string = text.string

	font = text.font
	font_name = font.font_name

	return font_name, x, y, height, string
end



end
end