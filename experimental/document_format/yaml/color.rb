module Gosu


class Color
	def to_yaml_type
		"!ruby/object:#{self.class}"
	end

	def encode_with(coder)
		coder.represent_scalar to_yaml_type, to_string_representation
	end

	def init_with(coder)
		hex_number = coder.scalar.to_i(16)
		initialize(hex_number)
	end

	def to_string_representation
		self.pack.to_s(16)
	end

	def self.from_string_representation(string_representation)
		hex_number = string_representation.to_i(16)
		self.unpack(hex_number)
	end
end



end