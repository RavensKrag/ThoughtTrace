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
		# TODO: how do I get the previous value? Need to know what the position of B was after the end of the last tick of this constraint. Can't currently store in in the instance variables of this constraint object, as the constraint object is shared between multiple constraint pairs.
		# but it should be noted that I built the system this way because I assumed that there would need to be stored state within a constraint. If that assumption was incorrect, maybe some things need to be reconsidered.
		
		# could take the parameter closure out of the constraint, and store in in the Package, I suppose?
		
		
		
		# need to figure out if you need some arbitrary state tracking, of if you only need to track the data in the cache (both this state, and the previous state)
		# if you only need cache data, this is pretty simple
		# if you need arbitrary state permanence, then this is gonna get complicated
		# (I think you only need the cache data, but need to make sure)
				
		
		prev = 
		delta = b[:physics].body.p - prev
		
		# NOTE: this may bug out, as idk how well += works with Chipmunk vectors
		a[:physics].body.p += delta
	end
end


end
end