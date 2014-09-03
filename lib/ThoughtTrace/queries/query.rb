module ThoughtTrace
	module Queries


class Query
	# ===== callbacks for particular query events =====
	# --- these (unfortunately) have to be public, because they are called by the CollisionHandler
	
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
	
	
	
	
	
	
	
	
	# ===== serialization =====
	# convert ONE object to / from array on pack / unpack
	def pack(entity_to_id_table)
		entity_id = entity_to_id_table[@bound_entity]
		
		
		return [entity_id]
	end
	
	
	class << self
		def unpack(
			id_to_entity_table, space, # provided by system
			id # loaded from file
		)
		# ---
			# 'args' array contains only elements stored in the file on disk
			query = self.new(space)
			
			
			
			entity = id_to_entity_table[id]
			
			query.bind(entity)
			
			
			return query
		end
	end
	# =========================
end



end
end