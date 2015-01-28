module ThoughtTrace
	module Constraints



# Always move A relative to B
# ( sorta like B is the Parent, and A is the Child )
class MoveRelative
	# accept parameters that can be used to alter the #call step
	def initialize
		
	end

	# list the things that will be changed
	# needed to figure out when the entities are changing

	# dependency, prerequisite?
	# (is it a concurrent dependency? - interrelated, correlated)
	def foo(a,b)
		[
			b[:physics].body.p
		]
	end

	# execute one tick
	def call(a,b)
		# how do I get the previous value?
		prev = 
		delta = b[:physics].body.p - prev
		
		# NOTE: this may bug out, as idk how well += works with Chipmunk vectors
		a[:physics].body.p += delta
	end
end


end
end