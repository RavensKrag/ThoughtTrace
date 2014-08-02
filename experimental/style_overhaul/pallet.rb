# Holds a variety of styles
class Pallet
	def initialize
		@collection = Hash.new
	end
	
	
	def [](k)
		@collection[k]
	end
	
	def []=(k,v)
		@collection[k] = v
	end
end