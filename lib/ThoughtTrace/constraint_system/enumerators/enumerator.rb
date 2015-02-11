module ThoughtTrace
	module Constraints
		module Enumerators


# NOTE: maybe don't name this Enumerator?

# class is named Enumerator
# because it is a special kind of... enumerator
# but there is a core class called Enumerator
# and simply using name-spacing alone to distinguish them makes it really easy to get the wrong one
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