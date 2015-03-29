module ThoughtTrace
	module Style


class StyleObject
	# attr_accessor :name
	# defining this manually so you can lock the name property
	
	def initialize(name="")
		@name = name
		@properties = Hash.new
	end
	
	def ==(other)
		return false unless other.is_a? self.class
		
		return @properties.all?{ |k,v|  v == other[k] }
	end
	
	alias :eql? :==
	
	
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
	
	
	def lock_name!
		@lock = true
	end
	
	def name=(arg)
		if @lock
			raise "Style '#{@name}' has a locked name. This name can not be changed." 
			@lock.freeze! unless @lock.frozen?
			# need to put the freeze here, because of serialization
			# not sure how to serialize the frozen status
		end
		@name = arg
	end
	
	def name
		@name
	end
end



end
end