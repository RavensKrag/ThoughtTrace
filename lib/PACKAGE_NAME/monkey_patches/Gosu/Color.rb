require './serialization/serializable'

module Gosu
	class Color
		include TextSpace::Serializable
		
		def init_with coder
			args = YAML.load(coder.scalar)
			initialize(*args)
		end

		def to_string_representation
			hex_value = 0
			[:alpha, :red, :green, :blue].each do |channel|
				hex_value = hex_value << 8
				hex_value = hex_value | self.send(channel)
			end
			
			hex_value.to_yaml
		end
		
		class << self
			def from_string_representation(string_representation)
				args = YAML.load(string_representation)
				new(*args)
			end
		end
	end
end