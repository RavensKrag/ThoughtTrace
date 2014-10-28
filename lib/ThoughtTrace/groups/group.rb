module ThoughtTrace
	module Groups


class Group
	CASCADE_NAME = :group
	
	def initialize
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
		obj[:style].tap do |component|
			component.edit(CASCADE_NAME) do |x|
				x.socket(1, @style)
			end
			
			component.mode = CASCADE_NAME
		end
		
		
		@entities << obj
	end
	
	def remove(obj)
		# TODO: remove style from obj
		obj[:style].delete CASCADE_NAME
		
		@entities.delete obj
	end
	
	
	
	
	
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
