module ThoughtTrace
	module Constraints


class Closure
	def pack
		# not used
	end
	
	
	def unpack(data)
		@vars = HashWrapper.new(data)
	end
end



end
end