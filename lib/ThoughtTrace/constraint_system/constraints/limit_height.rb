module ThoughtTrace
	module Constraints


class LimitHeight < Constraint
	# accept parameters that can be used to alter the #call step
	def initialize
		super()
	end
	
	def self.foo(a,b)
		[
			a[:physics].shape.height,
			b[:physics].shape.height
		]
	end

	# execute one tick
	def call(a,b)
		ah = a[:physics].shape.height
		bh = b[:physics].shape.height
		
		# the height of B should not exceed the height of A
		# (passing A through the constraint allows the value to be further constrained)
		if bh > ah
			b[:physics].shape.height = @closure.call(a[:physics].shape.height)
		end
	end
	# TODO: need to figure out if the method aliasing from the default constraint will still work, and allow this definition of #call to be triggered via #[] interface
end



end
end