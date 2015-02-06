# module ThoughtTrace
# 	module Queries


class EntityMarkerCollider
	def begin(arbiter)
		
	end

	def pre_solve(arbiter)
		# bind target to entity
		# (activate binding)
		
		# TODO: make sure this only ticks once. maybe this goes in the #begin block? idk
		marker, target = parse_arbiter(arbiter)
		marker.consider target   # add to list of potential targets (disambiguation is required)
	end

	def post_solve(arbiter)
		
	end

	def separate(arbiter)
		# bind target to marker
		# (restore to default)
		marker, target = parse_arbiter(arbiter)
		marker.unconsider target # remove from the list of potential targets
		# TODO: (need a better name of this)
	end
	
	
	
	private
	
	
	def parse_arbiter(arbiter)
		marker = arbiter.a.obj
		target = arbiter.b.obj
		
		
		return marker, target
	end
end



# end
# end