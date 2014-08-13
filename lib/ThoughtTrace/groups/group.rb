module ThoughtTrace
	module Groups


class Group
	def initialize(space)
		@space = space
		
		@entities = Array.new
		
		@style = ThoughtTrace::Style::StyleObject.new
		@style.tap do |s|
			s[:color] = Gosu::Color.argb(0xaa69BDA7)
			s[:hitbox_color] = Gosu::Color.argb(0xffFFFFFF)
		end
	end
	
	
	
	
	
	def update
		
	end
	
	def draw
		
	end
	
	def gc?
		
	end
	
	
	
	
	
	def add(obj)
		obj[:style].mode = :group
		obj[:style].socket(1, @style)
		
		@entities << obj
	end
	
	def remove(obj)
		@entities.delete obj
	end
	
	
	
	
	
	# ===== serialization =====
	# convert ONE object to / from array on pack / unpack
	def pack(entity_to_id_table)
		entity_id_list = @entities.collect{ |e|  entity_to_id_table[e] }
		
		return entity_id_list
	end
	
	
	class << self
		def unpack(
			id_to_entity_table, space, # provided by system
			*entity_id_list # loaded from file
		)
		# ---
			# 'args' array contains only elements stored in the file on disk
			group = self.new(space)
			
			
			entities = entity_id_list.collect{ |id|  id_to_entity_table[id] }
			entities.each do |e|
				
				# DO ACTUAL STUFF HERE
				group.add e
				
			end
			
			
			return group
		end
	end
	# =========================
end



end
end
