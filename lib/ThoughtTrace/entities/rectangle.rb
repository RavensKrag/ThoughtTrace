module ThoughtTrace


class Rectangle < Entity
	def initialize(width, height)
		# TODO: Update geometry when style is updated, and vice versa. (or else maybe width and height shouldn't be stored in Style)
					body = CP::Body.new(Float::INFINITY, Float::INFINITY)
					shape = CP::Shape::Rect.new body, width, height
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
	
	
	
	
	
	def resize!(grab_handle, coordinate_space=nil, point:nil, delta:nil, minimum_dimension:1, lock_aspect:false, limit_by:nil)
		
		# save
		original_verts    = self[:physics].shape.verts
		original_position = self[:physics].body.p.clone
		
		# process
		self[:physics].shape.resize!(
			grab_handle, coordinate_space, point:point, delta:delta,
			minimum_dimension:minimum_dimension, lock_aspect:lock_aspect, limit_by:limit_by
		)
		
		# return proc to reverse the process
		undo = Proc.new do
			self[:physics].shape.set_verts!(original_verts, CP::Vec2.new(0,0))
			self[:physics].body.p = original_position
		end
		
		return undo
	end
end



end