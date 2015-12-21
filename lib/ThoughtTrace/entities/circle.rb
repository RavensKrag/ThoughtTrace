module ThoughtTrace


class Circle < Entity
	def initialize(radius)
		# TODO: Update geometry when style is updated, and vice versa. (or else maybe width and height shouldn't be stored in Style)
					body = CP::Body.new(Float::INFINITY, Float::INFINITY)
					shape = CP::Shape::Circle.new body, radius
		physics = ThoughtTrace::Components::Physics.new self, body, shape
		
		super(physics)
		
		
		
		
		
		# TODO: cascade into default style
		@components[:style].edit(:default) do |s|
			s[:color] = Gosu::Color.argb(0xaa2A3082)
		end
		
		@components[:style].edit(:hover) do |s|
			s[:color] = Gosu::Color.argb(0xaa0000FF)
		end
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		@components[:physics].draw @components[:style][:color], z_index
	end
	
	
	
	
	
	def resize!(coordinate_space=nil, radius:nil, point:nil, delta:nil, minimum_dimension:1)
		
		# NOTE: could accept a grab handle, but Circle really doesn't need one, so it would just be ignored anyway
		
		# TODO: consider that you should always use a local point, and just require that the user transform the world-space point into a local-space one outside of the resize system.
		
		
		# these argument-checking statements are ripped straight from Shape::Rect
		# NOTE: needs to be updated. circle has 3 parameters [radius, point, delta] from which only one parameter may be set at any given time
		raise ArgumentError, "Declare point OR delta, not both." if point and delta
		raise ArgumentError, "Must declare either point OR delta." unless point or delta
		
		unless [:world_space, :local_space].include?(coordinate_space)
			raise ArgumentError, "Coordinate space must either be :world_space or :local_space" 
		end
		
		
		# save
		old_radius = self.radius
		
		
		# process
		new_radius = 
			if radius
				radius
			elsif delta
				self.radius + delta
			elsif point
				p = self.body.p
				p.dist point
			end
		
		new_radius = [new_radius, minimum_dimension].max
		
		self.radius = new_radius
		
		
		# return proc to reverse the process
		undo = Proc.new do
			self.radius = old_radius
		end
		
		return undo
	end
	
	
	
	def radius
		@components[:physics].shape.radius
	end
	
	def radius=(r)
		@components[:physics].shape.set_radius! r
	end
end



end