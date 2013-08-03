module TextSpace
	module Serializable
		def to_yaml_type
			self.class.const_get(:YAML_TYPE)
		end

		def encode_with coder
			coder.represent_scalar to_yaml_type, to_string_representation
		end

		def init_with coder
			raise "Method #{self.name}.init_with not defined."
		end

		def to_string_representation
			raise "Method #{self.name}.to_string_representation not defined."
		end
		
		class << self
			def from_string_representation(string_representation)
				raise "Method #{self.name}.from_string_representation not defined."
			end
			
			def included(base)
				unless base.const_defined?(:YAML_TYPE)
					base.const_set :YAML_TYPE, "tag:example.com,2012-06-28/#{base.name}"
				end
				
				YAML.add_tag base.const_get(:YAML_TYPE), base
			end
		end
	end
end
