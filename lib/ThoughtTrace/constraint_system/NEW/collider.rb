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
		marker.bind_to target
	end

	def post_solve(arbiter)
		
	end

	def separate(arbiter)
		# bind target to marker
		# (restore to default)
		marker, target = parse_arbiter(arbiter)
		marker.unbind
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