module ThoughtTrace
	module Constraints


class Constraint
	# are constraints always pairwise?
	# not sure if I can even make that call right now
	
	
	# bind constraint to entity objects
	def initialize(*entity_list)
		@entities = entity_list
	end
	
	
	# apply one tick of the constraint
	def update
		raise "Constraint #{self.class} does not implement #update"
	end
	
	# visualize the current state of the constraint
	def draw
		raise "Constraint #{self.class} does not implement #draw"
	end
	
	
	
	def gc?
		false
	end
	
	
	
	# bind
	# unbind
	# unbind_when # defines a condition. if the condition is true, then do the unbinding procedure
	# 	# (allows for "break the tether"-style triggers)
	# update
	# draw
	
	
	
	
	
	
	# ===== serialization =====
	# convert ONE object to / from array on pack / unpack
	def pack
		return @entities.clone
	end
	
	
	class << self
		def unpack(*entities)
			constraint = self.new(*entities)
			
			return constraint
		end
	end
	# =========================
end



end
end