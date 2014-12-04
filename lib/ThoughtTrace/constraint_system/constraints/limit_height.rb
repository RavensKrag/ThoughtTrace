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
		
	end
end


end
end