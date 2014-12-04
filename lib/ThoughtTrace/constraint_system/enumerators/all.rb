module ThoughtTrace
	module Constraints
		module Enumerators



# n-way
class All < Enumerator
	def all_pairs(&block)
		@entities.permutation(2) do |a,b|
			block.call(a,b)
		end
	end
	
	
	def update_condition(entity)
		
	end
end


end
end
end