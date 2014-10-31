entity[:style].cascade(:default)



entity[:style].tap |component|
	component.mode = :query
	component.socket(1, @style)
	component.socket(2, component.cascade(:default)) # TODO: implement cascade access ASAP
end








entity[:style].mode = MODE_NAME

entity[:style].active_cascade.tap |x|
	x.mode = :query
	x.socket(1, @style)
	x.socket(2, x.cascade(:default)) # TODO: implement cascade access ASAP
end