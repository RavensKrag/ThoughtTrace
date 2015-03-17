module ThoughtTrace
	module Groups


class Group
	def initialize
		@entities = Array.new
	end
	
	
	
	
	
	def update
		
	end
	
	def draw
		# TODO: consider just drawing a visual overlay to show what elements are in the group, rather than creating a group style for each group
		# could still use style objects to control the properties of this overlay, however
		
		
		# some groups could assign styles to their members, but I don't think it's necessary to visualize "being in a group" with the assignment of a style
		# groups probably shouldn't be visible all the time anyway
		# (allows for better use of groups as an abstraction tool)
		
		
	end
	
	def gc?
		
	end
	
	
	
	
	
	def add(obj)
		@entities << obj
	end
	
	def remove(obj)
		@entities.delete obj
	end
	
	def clear
		@entities.clear
	end
	
	def each(&block)
		@entities.each &block
	end
	
	include Enumerable
	
	
	
	
	
	# ===== serialization =====
	# convert ONE object to / from array on pack / unpack
	def pack
		return @entities.clone
	end
	
	
	class << self
		def unpack(*entities)
			group = self.new
			
			entities.each{ |e| group.add e  }
			
			return group
		end
	end
	# =========================
end



end
end
