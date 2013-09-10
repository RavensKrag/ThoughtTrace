module CP
	class Vec2
		include TextSpace::Serializable
		
		def clone
			return CP::Vec2.new(self.x, self.y)
		end
		
		def init_with coder
			args = YAML.load(coder.scalar)
			initialize(*args)
		end

		def to_string_representation
			[self.x, self.y].to_yaml
		end
		
		class << self
			def from_string_representation(string_representation)
				args = YAML.load(string_representation)
				new(*args)
			end
		end
	end
end