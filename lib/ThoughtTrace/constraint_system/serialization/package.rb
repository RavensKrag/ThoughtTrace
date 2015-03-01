module ThoughtTrace
	module Constraints


class Package
	def pack
		# NOTE: could also access A and B through the @pair
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
	
	
	def self.unpack(data)
		m1, m2, e1, e2, constraint, visualization, visibility = data
		
		self.new(constraint, visualization).tap do |obj|
			obj.instance_eval do
				@marker_a = m1
				@marker_b = m2
				
				@marker_a.bind_to(e1)
				@marker_b.bind_to(e2)
				
				@visible  = visibility
				
				update_bindings()
			end
		end
	end
end



end
end