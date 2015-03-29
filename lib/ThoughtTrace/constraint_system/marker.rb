module ThoughtTrace
	module Constraints


class Marker < ThoughtTrace::Circle
	attr_reader :constraint_target, :render_target
	
	RADIUS = 10
	
	def initialize
		super(RADIUS)
		
		@constraint_target = nil  # entity to feed into the constraint
		@render_target     = self # entity to feed into visualization
		
		# TODO: need to set collision type to something distinct from the default Entity collision type
		# TODO: should probably develop a nice visual style to make it clear that this is the marker object
		# TODO: consider always rendering markers on top of entities or something like that
			# maybe like this...?
				# constraint visualization
				# marker
				# entity
		
		@components[:style].edit(:default)  do |s|
			s[:color] = Gosu::Color.argb(0xaa0BF0F1)
		end
	end
	
	def update
		super()
		
		# TODO: consider doing this by constraint or something, because you don't really want to recalculate the center all the time.
		if @constraint_target
			p = @constraint_target[:physics].center
			@components[:physics].body.p = p
		end
	end
	
	def draw(z_index=0)
		super(z_index)
	end
	
	
	# TODO: should change visualization state on bind / unbind, so that the UI can show this state change to the user
	def bind_to(entity)
		@constraint_target = entity
		@render_target     = entity
		
		@components[:physics].body.p = entity[:physics].center
	end
	
	def unbind
		@constraint_target = nil
		@render_target     = self
	end
end



end
end