module ThoughtTrace
	module Queries


class Query
	# ===== callbacks for particular query events =====
	
	# called once when the Query first detects an Entity
	def on_add(space, entity)
		
	end
	
	# called every tick while the Query is aware of the Entity
	def on_tick(space, entity)
		# maybe this should be in #update?
		# maybe #update should only be for updating the Query itself?
		
	end
	
	# called once when the Query first loses track of an Entity
	def on_remove(space, entity)
		
	end
end



end
end