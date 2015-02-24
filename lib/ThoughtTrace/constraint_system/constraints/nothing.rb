module ThoughtTrace
	module Constraints



# Dummy constraint. Performs no action.
# Useful for testing visualizations.
class Nothing < Constraint
	# accept parameters that can be used to alter the #call step
	def initialize
		
	end

	def foo(a,b)
		false # never run the tick
	end

	# execute one tick
	def call(a,b)
		# do nothing
		# but it will never be run anyway
	end
end


end
end