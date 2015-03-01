module ThoughtTrace
	module Constraints


class Constraint
	attr_reader :closure
	
	def initialize(closure=nil)
		@closure = closure
		@closure ||= Closure.new
		
		# closures could technically be shared between different Constraint instances,
		# but if you need to share a parameterized constraint of the same type,
		# you would always link to the same parameterized constraint object, or do a deep copy.
		# (deep copy is for basing a new constraint off an existing one)
		# 
		# The only reason to share Closure objects between different Constraints,
		# is if the same closure would be relevant to two different Constraint types.
	end
	
	
	# check cache things
	# (this is the format of the data stored in @cache)
	def foo(a,b)
		# example only.
		# in production code, the base class implementation should return a blank array
		# (idk what to do for a lower-level implementation stub. hopefully that's unnecessary?)
		# (lower-level implementations will change the values of a pre-allocated block, rather than returning newly allocated data)
		[
			a[:physics].body.p 
		]
	end
	
	# execute one tick on the provided A and B pair
	# should not mutate cache, should not store any state in the Constraint object
	# (the Constraint object is shared between many Pairs)
	def call(a,b, cache)
		# @closure
	end
	
	
	
	# create a deep copy of this Constraint
	def clone
		self.class.new(self.closure.clone)
	end
end



end
end