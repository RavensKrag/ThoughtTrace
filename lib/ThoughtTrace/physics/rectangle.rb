module ThoughtTrace
	module Physics


# Includes basic physics shape properties, as well as "counter-steering" code
# to allow for changing the shape while making it feel like certain elements are locked in place
class Rectangle < CP::Shape::Rect
	def initialize(body, width, height)
		offset = CP::Vec2.new(0,0)
		super(body, width, height, offset)
	end
end



end
end