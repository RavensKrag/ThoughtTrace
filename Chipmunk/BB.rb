require 'yaml'

require './Serializable'

module CP
	class BB
		def area
			(self.r - self.l) * (self.t - self.b)
		end
		
		def center
			CP::Vec2.new(self.l+width/2, self.b+height/2)
		end
		
		def height
			self.t - self.b
		end
		
		def width
			self.r - self.l
		end
		
		
		include TextSpace::Serializable
		
		def init_with coder
			args = YAML.load(coder.scalar)
			initialize(*args)
		end

		def to_string_representation
			[self.l, self.b, self.r, self.t].to_yaml
		end
		
		class << self
			def from_string_representation(string_representation)
				args = YAML.load(string_representation)
				new(*args)
			end
		end
	end
end