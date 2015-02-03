class EntityMarker < ThoughtTrace::Circle
	attr_reader :constraint_target, :render_target
	
	RADIUS = 20
	
	def initialize
		super(RADIUS)
		
		@constraint_target = nil  # entity to feed into the constraint
		@render_target     = self # entity to feed into visualization
	end
	
	def update
		super()
	end
	
	def draw(z_index=0)
		super(z_index)
		
		
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