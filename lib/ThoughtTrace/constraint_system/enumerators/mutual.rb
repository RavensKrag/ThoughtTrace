module ThoughtTrace
	module Constraints
		module Enumerators



# 2-way
class Mutual < Enumerator
	def each(&block)
		[
			[@entities[0], @entities[1]],
			[@entities[1], @entities[0]]
		].each do |a,b|
			block.call(a,b)
		end
	end
end


end
end
end