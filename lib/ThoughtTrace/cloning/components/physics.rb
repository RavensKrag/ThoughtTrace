module ThoughtTrace
	module Components


class Physics < Component
	def clone
		body = @body.clone
		shape = @shape.clone
		parent = @shape.obj
		
		
		
		other = self.class.new parent, body, shape
		return other
	end
end



end
end