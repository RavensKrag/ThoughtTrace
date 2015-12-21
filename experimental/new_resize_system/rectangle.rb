class Rectangle < Entity
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
