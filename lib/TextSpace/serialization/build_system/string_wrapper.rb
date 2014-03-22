# wraps the string class, so I don't have to pollute String with monkey patches
# that only apply to the build system
# (I think it's more like just part of the system at that)

# Contains manipulations to turn the 'load' body into the 'dump' body
module TextSpace



class StringWrapper
	attr_reader :string
	
	def initialize(string)
		@string = string
	end
	
	
	def strip_comments
		@string = @string.strip_comment
		
		return self
	end
	
	# x = a --> a = x
	def reverse_assignment
		@string = @string.split('=').collect{ |i| i.strip }.reverse.join(' = ')
		
		return self
	end
end


end