module ThoughtTrace
	module Queries


# add / remove things from the set of things to be queried
class CollisionHandler
	def initialize(space)
		@space = space
	end
	
	
	def begin(arbiter)
		query_object, entity = parse_arbiter(arbiter)
		
		if true # some condition for collision
			query_object.on_add @space, entity
			
			
			return true
		else 
			return false
		end
	end

	def pre_solve(arbiter)
		query_object, entity = parse_arbiter(arbiter)
		
		query_object.on_tick @space, entity
	end

	# def post_solve(arbiter)
	# 	query_object, entity = parse_arbiter(arbiter)
		
		
	# end

	def separate(arbiter)
		query_object, entity = parse_arbiter(arbiter)
		
		query_object.on_remove @space, entity
	end
	
	
	private
	
	
	def parse_arbiter(arbiter)
		query_object = arbiter.a.obj[:query].callbacks
		entity       = arbiter.b.obj
		
		
		return query_object, entity
	end
end



end
end