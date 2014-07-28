require 'yaml'

module ThoughtTrace
	module Style


class Pallet
	def initialize
		@styles = Hash.new
		# {:name => {:property => value}}
	end
	
	def [](name)
		return @styles[name]
	end
	
	def []=(name, value) 
		@styles[name] = value
	end
	
	
	def ==(other)
		return @styles.all?{ |k,v|  v == other[k] }
	end
	
	
	# is there any reason for StyleObject to be it's own custom class?
	# I kinda don't want arbitrary Hash objects thrown into this collection
	# but there's not really a good way to stop that
	# unless you violate duck typing, in favor of a stricter type system
	# which is kinda bad in the context of Ruby
	
	
	
	def pack
		collection =
			@styles.collect do |name, style|
				[name, style.pack]
			end
		
		collection = collection.to_h
		
		return collection
	end
	
	class << self
		def unpack(property_hash)
			obj = self.new
			
			
			property_hash.each do |style_id, style_data|
				style = ThoughtTrace::Style::StyleObject.unpack style_data
				obj[style_id] = style
			end
			
			return obj
		end
	end
	
	
	
	
	def dump(filepath)
		data = self.pack
		
		File.open(filepath, 'w') do |f|
			YAML.dump(data, f)
		end
	end
	
	class << self
		def load(filepath)
			data = YAML.load_file(filepath)
			obj = self.unpack data
			
			return obj
		end
	end
end



end
end