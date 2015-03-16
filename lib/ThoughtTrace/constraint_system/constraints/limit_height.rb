module ThoughtTrace
	module Constraints


class LimitHeight < Constraint
	# check cache things
	# (this is the format of the data stored in @cache)
	def foo(a,b)
		[
			a[:physics].shape.height,
			b[:physics].shape.height
		]
	end
	
	# execute one tick on the provided A and B pair
	# should not mutate cache, should not store any state in the Constraint object
	# (the Constraint object is shared between many Pairs)
	def call(a,b, cache) # @closure
		ah = a[:physics].shape.height
		bh = b[:physics].shape.height
		
		# the height of B should not exceed the height of A
		# (passing A through the constraint allows the value to be further constrained)
		desired_height = @closure.call(a[:physics].shape.height)
		if bh > desired_height
			b[:physics].shape.height = desired_height
		end
	end
	
	
	# TODO: need to figure out if the method aliasing from the default constraint will still work, and allow this definition of #call to be triggered via #[] interface
end



end
end