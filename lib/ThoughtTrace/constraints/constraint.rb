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
	
	
	
	
	
	
	
	# ===== serialization =====
	# convert ONE object to / from array on pack / unpack
	def pack
		return @entities.clone
	end
	
	
	class << self
		def unpack(*entities)
			constraint = self.new
			
			entities.each{ |e| constraint.add e  }
			
			return constraint
		end
	end
	# =========================
end



end
end