module ThoughtTrace
	module Queries


COLLISION_TYPE = :query

class Query
	# ===== callbacks for particular query events =====
	
	# called once when the Query first detects an Entity
	def on_add(space, entity)
		warn "#{self.class}#on_add is not defined"
	end
	
	# called every tick while the Query is aware of the Entity
	def on_tick(space, entity)
		# maybe this should be in #update?
		# maybe #update should only be for updating the Query itself?
		
		warn "#{self.class}#on_tick is not defined"
	end
	
	# called once when the Query first loses track of an Entity
	def on_remove(space, entity)
		warn "#{self.class}#on_remove is not defined"
	end
end



end
end