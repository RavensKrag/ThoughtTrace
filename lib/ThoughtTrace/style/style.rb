module ThoughtTrace
	module Style


class StyleObject
	attr_accessor :name
	
	def initialize(name="")
		@name = name
		@properties = Hash.new
	end
	
	def ==(other)
		return false unless other.is_a? self.class
		
		return @properties.all?{ |k,v|  v == other[k] }
	end
	
	
	# read property
	def [](property)
		return @properties[property]
	end
	
	# write property
	def []=(property, value)
		@properties[property] = value
	end
	
	def has_property?(property)
		@properties.has_key? property
	end
end



end
end