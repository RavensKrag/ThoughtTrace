require File.expand_path '../../../utilities/serialization/serializable', __FILE__

module CP
	class Vec2
		class << self
			# Return the angle between two vectors
			def angle_between(v1, v2)
				# normalization of zero vectors results in NaN, which is really bad
				v1 = v1.normalize unless v1.zero?
				v2 = v2.normalize unless v2.zero?
				
				cos = v1.dot v2
				
				theta = Math::acos(cos)
				
				return theta
			end
		end
		
		def zero?
			return self.x == 0 && self.y == 0
		end
		
		def to_screen_space
			return self - $window.camera.offset
		end
		
		def to_world_space
			return self + $window.camera.offset
		end
		
		def clone
			return CP::Vec2.new(self.x, self.y)
		end
		
		
		include TextSpace::Serializable
		
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