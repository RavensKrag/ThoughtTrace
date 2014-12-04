module ThoughtTrace
	module Constraints
		module Enumerators



# n-way
class All < Enumerator
	def each(&block)
		@entities.permutation(2) do |a,b|
			block.call(a,b)
		end
	end
end


end
end
end