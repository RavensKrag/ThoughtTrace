module ThoughtTrace
	module Constraints
		module Enumerators



# 1-way
class Directed < Enumerator
	def all_pairs(&block)
		block.call(@entities[0], @entities[1])
	end
	
	def update_condition(entity)
		
	end
end



end
end
end



