module ThoughtTrace
	module Constraints



class SyncHeight < Constraint
	# accept parameters that can be used to alter the #call step
	def initialize
		
	end

	def foo(a,b)
		[
			a[:physics].height
		]
	end

	# execute one tick
	def call(a,b)
		b[:physics].height = a[:physics].height
	end
end


end
end