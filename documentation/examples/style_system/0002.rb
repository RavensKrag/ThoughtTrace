component = entity[:style]

default_cascade = component.cascade(:default)

component.mode = :query
component.active_cascade.tap do |x|
	x.socket(1, @style)
	x.socket(2, default_cascade)
end
