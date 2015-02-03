class EntityMarker
	attr_reader :constraint_target, :render_target
	
	def initialize
		@constraint_target = nil
		@render_target     = nil
	end
	
	def update
		# move position to match the position of the tracked Entity, if any
		# (by which I mean the constraint target)
	end
	
	def draw
		
	end
	
	
	
	
	def bind_to(entity)
		@constraint_target = entity
		@render_target     = entity
	end
	
	def unbind
		@constraint_target = nil
		@render_target     = self
	end
end