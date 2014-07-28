module ThoughtTrace
	module Style


class Pallet
	def initialize(name)
		@name = name
		@project = "project/path/goes/here/"
		
		@styles = Hash.new
		# {:name => {:property => value}}
	end
	
	def [](name)
		return @styles[name]
	end
	
	def []=(name, value) 
		@styles[name] = value
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
		
		return [@name, collection]
	end
	
	class << self
		def unpack(data)
			name, property_hash = data
			obj = self.new name
			
			
			property_hash.each do |style_id, style_data|
				style = ThoughtTrace::Style::StyleObject.unpack style_data
				obj[style_id] = style
			end
			
			return obj
		end
	end
end



end
end