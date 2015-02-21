# The graphical interface elements of a Constraint
# (kinda like a Decorator: adds extra stuff on top of the standard Constraint functionality)
# (can use the Constraint objects directly if you don't need visualization. ex: optimization)
class ConstraintPackage
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
	
	
	class << self
	def unpack(data)
		
	end
	end
end