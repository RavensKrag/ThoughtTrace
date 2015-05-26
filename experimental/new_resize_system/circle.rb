class Circle
	def resize!(coordinate_space=nil, radius:nil, point:nil, delta:nil, minimum_dimension:1, lock_aspect:false, limit_by:nil)
		
		# NOTE: could accept a grab handle, but Circle really doesn't need one, so it would just be ignored anyway
		
		
		old_radius = self.radius
		
		@components[:physics].shape.resize!(
			coordinate_space, radius:radius, point:point, delta:delta,
			minimum_dimension:minimum_dimension, lock_aspect:lock_aspect, limit_by:limit_by
		)
		
		
		undo = Proc.new do
			@components[:physics].shape.set_radius! old_radius
		end
		
		return undo
	end
end





module CP
	module Shape
	
class Circle
	def resize!(coordinate_space=nil, radius:nil, point:nil, delta:nil, minimum_dimension:1, lock_aspect:false, limit_by:nil)
		
		
		# these argument-checking statements are ripped straight from Shape::Rect
		# NOTE: needs to be updated. circle has 3 parameters [radius, point, delta] from which only one parameter may be set at any given time
		raise ArgumentError, "Declare point OR delta, not both." if point and delta
		raise ArgumentError, "Must declare either point OR delta." unless point or delta
		
		unless [:world_space, :local_space].include?(coordinate_space)
			raise ArgumentError, "Coordinate space must either be :world_space or :local_space" 
		end
		
		
		r = self.radius
		
		new_radius = 
			if radius
				radius
			elsif delta
				r + delta
			elsif point
				p = self.body.p
				p.dist point
			end
		
		self.set_radius!(new_radius)
	end
end


end
end