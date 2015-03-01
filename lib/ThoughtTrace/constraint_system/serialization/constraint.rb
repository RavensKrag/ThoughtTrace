module ThoughtTrace
	module Constraints


class Constraint
	def pack
		return @closure.vars.to_h
	end
	
	
	def unpack(data)
		@closure.unpack data
	end
end



end
end