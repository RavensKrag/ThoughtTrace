module ThoughtTrace
	module Constraints


class Constraint
	def pack
		return @closure.vars.to_h
	end
	
	
	def self.unpack(data)
		closure = Closure.unpack data
		return self.new(closure)
	end
end



end
end