module ThoughtTrace
	module Constraints
		module Enumerators



# 2-way
class Mutual < Enumerator
	def all_pairs(&block)
		[
			[@entities[0], @entities[1]],
			[@entities[1], @entities[0]]
		].each do |a,b|
			block.call(a,b)
		end
	end
	
	def update_condition(entity)
		
	end
end


end
end
end