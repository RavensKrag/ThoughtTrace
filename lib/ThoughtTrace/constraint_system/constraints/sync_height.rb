module ThoughtTrace
	module Constraints



class SyncHeight < Constraint
	# check cache things
	# (this is the format of the data stored in @cache)
	def foo(a,b)
		[
			a[:physics].height
		]
	end
	
	# execute one tick on the provided A and B pair
	# should not mutate cache, should not store any state in the Constraint object
	# (the Constraint object is shared between many Pairs)
	def call(a,b, cache) # @closure
		b[:physics].height = a[:physics].height
	end
end


end
end