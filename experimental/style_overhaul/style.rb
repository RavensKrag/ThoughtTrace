class StyleObject
	def initialize
		@properties = Hash.new
	end
	
	def [](property)
		return @properties[property]
	end
	
	def []=(property, value) 
		@properties[property] = value
	end
	
	def has_property?(property)
		@property.has_key? property
	end
end