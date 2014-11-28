
module Constraints



class Constraint
	def initialize
		
	end
end



class Collection
	def initialize
		@stored = [] # all known initialized constraints
		
		@foo = [] # constraints that are queued to be evaluated. (may or may not actually be run)
		@baz = [] # constraints that have been executed this tick
	end
	
	def add(c)
		@stored << c
	end
end


end