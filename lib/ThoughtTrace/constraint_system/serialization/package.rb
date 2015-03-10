module ThoughtTrace
	module Constraints


class Package
	def pack
		# NOTE: getting A and B accessable through Pair and Marker. Using Pair because that's the active binding.
		
		[
			@marker_a,
			@marker_b,
			@pair.a,
			@pair.b,
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