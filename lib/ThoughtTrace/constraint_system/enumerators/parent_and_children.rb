module ThoughtTrace
	module Constraints
		module Enumerators



# the first Entity in the list has the other Entities as children
class ParentAndChildren < Enumerators::Enumerator
	def each(&block)
		parent = @entities.first
		# discard the first element, without mutating the original list
		@entities.drop(1).each do |child|
			block.call(parent, child)
		end
	end
end


end
end
end