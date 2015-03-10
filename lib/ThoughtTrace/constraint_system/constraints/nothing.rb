module ThoughtTrace
	module Constraints



# Dummy constraint. Performs no action.
# Useful for testing visualizations.
class Nothing < Constraint
	# check cache things
	# (this is the format of the data stored in @cache)
	def foo(a,b)
		false # never run the tick
	end
	
	# execute one tick on the provided A and B pair
	# should not mutate cache, should not store any state in the Constraint object
	# (the Constraint object is shared between many Pairs)
	def call(a,b, cache) # @closure
		# do nothing
		# but it will never be run anyway
	end
end


end
end