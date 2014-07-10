# contains style-related values
# does not currently handle cascading
# does not handle different style modes
# (this is a really stripped down version of the style data block)

class Style
	def initialize
		@hash = Hash.new
	end
	
	def [](property)
		return @hash[property]
	end
	
	def []=(property, value) 
		@hash[property] = value
	end
	
	
	
	
	def pack
		
	end
	
	def self.unpack
		
	end
end