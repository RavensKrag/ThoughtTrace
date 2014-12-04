module ThoughtTrace
	module Constraints
		module Enumerators


class Enumerator
	# TODO: expand functionality to mirror the standard Enumerator class
	def initialize(entity_list)
		@entities = entity_list
	end
	
	
	def each(&block)
		
	end
	
	include Enumerable
end


end
end
end