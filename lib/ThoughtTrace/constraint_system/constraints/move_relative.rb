module ThoughtTrace
	module Constraints



# Always move A relative to B
# ( sorta like B is the Parent, and A is the Child )
class MoveRelative < Constraint
	# list the things that will be changed
	# needed to figure out when the entities are changing
	
	# check cache things
	# (this is the format of the data stored in @cache)
	def foo(a,b)
		[
			# if you don't clone, it will store a reference,
			# and that pointer will always point to the same data,
			# so the cache will never say the data is outdated.
			# TODO: consider saving x and y positions of the vector instead.
			b[:physics].body.p.clone
		]
	end
	
	# execute one tick on the provided A and B pair
	# should not mutate cache, should not store any state in the Constraint object
	# (the Constraint object is shared between many Pairs)
	def call(a,b, cache) # @closure
		return if cache.prev.nil? # cache doesn't always have a 'prev' value set
		# NOTE: this may be while this constraint is one frame behind
		# (may just fix this by running multiple constraint system ticks per render tick)
		
		
		prev = cache.prev[0]
		delta = b[:physics].body.p - prev
		delta = @closure.call(delta)
		
		# NOTE: this may bug out, as idk how well += works with Chipmunk vectors
		a[:physics].body.p += delta
	end
end


end
end