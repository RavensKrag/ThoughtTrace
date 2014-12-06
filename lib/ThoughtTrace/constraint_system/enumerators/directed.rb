module ThoughtTrace
	module Constraints
		module Enumerators



# 1-way
class Directed < Enumerators::Enumerator
	def each(&block)
		block.call(@entities[0], @entities[1])
	end
end



end
end
end



