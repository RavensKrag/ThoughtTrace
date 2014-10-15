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
	
	
	
	
	
	# the following two methods seem to be unnecessary
	# tested on ruby 2.1.1p76 (2014-02-24 revision 45161) [x86_64-linux] 
	# on Ubuntu Linux 14.04, installed through RVM
	def to_string_representation
		self.pack.to_s(16)
	end

	def self.from_string_representation(string_representation)
		puts "loading color"
		hex_number = string_representation.to_i(16)
		self.unpack(hex_number)
	end
end



end