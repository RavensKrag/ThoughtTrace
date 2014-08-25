module ThoughtTrace
	module Queries


# add / remove things from the set of things to be queried
class CollisionHandler
	def begin(arbiter)
		query_object, entity = parse_arbiter(arbiter)
		
		if true # some condition for collision
			query_object.on_add entity
			
			
			return true
		else 
			return false
		end
	end

	def pre_solve(arbiter)
		query_object, entity = parse_arbiter(arbiter)
		
		query_object.on_tick entity
	end

	# def post_solve(arbiter)
	# 	query_object, entity = parse_arbiter(arbiter)
		
		
	# end

	def separate(arbiter)
		query_object, entity = parse_arbiter(arbiter)
		
		query_object.on_remove entity
	end
	
	
	private
	
	
	def parse_arbiter(arbiter)
		query_object = arbiter.a.obj[:query].query
		entity       = arbiter.b.obj
		
		
		return query_object, entity
	end
end



end
end