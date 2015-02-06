class EntityMarker < ThoughtTrace::Circle
	attr_reader :constraint_target, :render_target
	
	RADIUS = 20
	
	def initialize
		super(RADIUS)
		
		@possible_targets = Set.new
		@size = @possible_targets.size
		
		@constraint_target = nil  # entity to feed into the constraint
		@render_target     = self # entity to feed into visualization
		
		# TODO: need to set collision type to something distinct from the default Entity collision type
		# TODO: should probably develop a nice visual style to make it clear that this is the marker object
		# TODO: consider always rendering markers on top of entities or something like that
			# maybe like this...?
				# constraint visualization
				# marker
				# entity
	end
	
	def update
		super()
		
		# the number of possible targets has changed since the last target disambiguation
		# (use this check to prevent the check from running unnecessarily)
		if @size != @possible_targets.size
			target = disambiguate_target()
			if target
				bind_to target
			else
				unbind
			end
			
			@size = @possible_targets.size # set the current count
		end
	end
	
	def draw(z_index=0)
		super(z_index)
		
		
	end
	
	
	
	
	
	
	def consider(entity)
		@possible_targets.add entity
	end
	
	def unconsider(entity)
		@possible_targets.delete entity
	end
	
	
	
	
	
		
	def bind_to(entity)
		@constraint_target = entity
		@render_target     = entity
	end
	
	def unbind
		@constraint_target = nil
		@render_target     = self
	end
	
	
	
	
	private
	
	def disambiguate_target
		target = nil
		
		@possible_targets.each do |entity|
			target ||= entity # if the list of possible targets is not empty, set it to something
			
			
		end
		
		return target
	end
end