module ThoughtTrace
	module Constraints


class Closure
	def pack
		# not used
	end
	
	
	def self.unpack(data)
		obj = self.new
		
		obj.instance_eval do
			@vars = HashWrapper.new(data)
		end
		
		return obj
	end
end



end
end