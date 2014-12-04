module ThoughtTrace
	module Constraints



class Constraint
	# accept parameters that can be used to alter the #call step
	def initialize
		
	end

	# list the things that will be changed
	# needed to figure out when the entities are changing

	# dependency, prerequisite?
	# (is it a concurrent dependency? - interrelated, correlated)
	def foo(a,b)
		[
			a[:physics].height
		]
	end

	# execute one tick
	def call(a,b)
		
	end
end


end
end