module ThoughtTrace
	module Style


class Pallet
	def initialize
		@styles = Hash.new
		# {:name => {:property => value}}
	end
	
	def [](key)
		
	end
	
	def []=(key, val)
		
	end
	
	
	# is there any reason for StyleObject to be it's own custom class?
	# I kinda don't want arbitrary Hash objects thrown into this collection
	# but there's not really a good way to stop that
	# unless you violate duck typing, in favor of a stricter type system
	# which is kinda bad in the context of Ruby
	
	
	
	def pack
		collection =
			@styles.inject do |name, style|
				[name, style.pack]
			end
		collection = collection.to_h
	end
	
	class << self
		def unpack(args)
			
		end
	end
end



end
end