module ThoughtTrace
	module Physics


# The height and width of a piece of text are related.
# This shape will control modulating the two values in sync.
# Thus, width changes with height, and height with width.
class Text < Rectangle
	def initialize(*args)
		super(*args)
	end
	
	
	# both height and width computation methods should compute new width and height values
	# the actual resizing of the font will be done with one call at the end
	# once the desired dimensions are calculated
	# 
	# each method should have the following:
	# 1) calculate new dimensions 
	# 2) transform collision shape based on new dimensions
	# 3) cache dimensions in proper instance variables
		# ^ this is actually handled by #resize! already
		# may need to make that clearer somehow
	
	
	# later, we'll mix in another step
	# 4) counter-steer as appropriate
	
	
	
	
	# NOTE:
	# the current resize logic is stored in the Text entity
	# this is because the new dimensions of the collision box are based on by typographic data
	# either the Entity would have to drive the transformation, and alter the shape,
	# or the shape would drive the transformation, and be pulling information implicitly from the Entity
	
	# but any way you look at it, it would mean you would have to know both parts to change the size, no?
	# not really, because the shape and entity are already tightly linked
	# each already knows about the other
		# the shape knows about the Entity for collisions
		# the Entity knows about the shape for encapsulation (holds the main pointer to the data)
	def width=(width)
		# simple ratio solution courtesy of this link
		# http://tech.pro/tutorial/691/csharp-tutorial-font-scaling
		
		
		# ratio of change in width
		ratio = width.to_f / @width.to_f
		
		height = @height * ratio # same proportional change in height
		
		
		
		self.resize! height, width
	end
	
	def height=(height)
		
		
		
		
		self.resize! height, width
	end
	
	
	# resizing
	
	
	# counter-steering
	
end



end
end