module ThoughtTrace
	module Constraints



class LimitHeight < Constraint
	# accept parameters that can be used to alter the #call step
	def initialize
		
	end

	def foo(a,b)
		[
			a[:physics].height,
			b[:physics].height
		]
	end

	# execute one tick
	def call(a,b)
		ah = a[:physics].height
		bh = b[:physics].height
		
		# the height of B should not exceed the height of A
		if bh > ah
			b[:physics].height = a[:physics].height
		end
	end
end


end
end