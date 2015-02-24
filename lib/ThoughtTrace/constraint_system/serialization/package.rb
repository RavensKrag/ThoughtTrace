# The graphical interface elements of a Constraint
# (kinda like a Decorator: adds extra stuff on top of the standard Constraint functionality)
# (can use the Constraint objects directly if you don't need visualization. ex: optimization)
module ThoughtTrace
	module Constraints


class Package
	def pack
		a = @marker_a.constraint_target
		b = @marker_b.constraint_target
		
		[
			@marker_a,
			@marker_b,
			a,
			b,
			@constraint,
			@visualization,
			@visible
		]
	end
	
	
	def unpack(data)
		m1, m2, e1, e2, constraint, visualization, visibility = data
		
		@marker_a = m1
		@marker_b = m2
		
		@marker_a.bind_to e1
		@marker_b.bind_to e2
		
		@constraint    = constraint
		@visualization = visualization
		@visible       = visibility
	end
end



end
end