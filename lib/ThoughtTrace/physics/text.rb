module ThoughtTrace
	module Physics


# The height and width of a piece of text are related.
# This shape will control modulating the two values in sync.
# Thus, width changes with height, and height with width.
class Text < Rectangle
	def initialize(*args)
		super(*args)
	end
	
	def width=(width)
		super(width)
	end
	
	def height=(height)
		super(height)
	end
end



end
end