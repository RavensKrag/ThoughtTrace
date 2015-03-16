module ThoughtTrace
	module Constraints


class Package
	def pack
		# NOTE: must retrieve A and B through Marker, because sometimes only one or the other is bound. Getting A and B through Pair only works when BOTH are bound.
		
		[
			@marker_a,
			@marker_b,
			@marker_a.constraint_target,
			@marker_b.constraint_target,
			@pair.constraint,
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
				
				@marker_a.bind_to(e1) if e1
				@marker_b.bind_to(e2) if e2
				
				@visible  = visibility
				
				update_bindings()
			end
		end
	end
end



end
end