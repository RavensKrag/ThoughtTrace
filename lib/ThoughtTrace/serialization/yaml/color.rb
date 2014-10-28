module Gosu


class Color
	def to_yaml_type
		"!ruby/object:#{self.class}"
	end

	def encode_with(coder)
		coder.represent_map to_yaml_type, {'value' => self.pack.to_s(16)}
	end

	def init_with(coder)
		hex_string = coder.map['value']
		hex_number = hex_string.to_i(16)
		initialize(hex_number)
	end
end



end