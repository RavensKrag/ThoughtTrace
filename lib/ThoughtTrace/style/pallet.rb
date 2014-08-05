module ThoughtTrace
	module Style


# Holds a variety of styles
class Pallet
	def initialize
		@collection = Hash.new
	end
	
	# def ==(other)
	# 	return @forward.all?{ |k,v|  v == other.get_style(k) }
	# end
	
	
	def [](k)
		warn "Style #{k} is not defined" unless @collection.has_key? k
		@collection[k]
	end
	
	def []=(k,v)
		@collection[k] = v
	end
end



end
end