class Text < Rectangle
	def resize!(grab_handle, coordinate_space=nil, point:nil, delta:nil, minimum_dimension:1)
		
		# save
			# should be the same as Rectangle entity
		original_verts    = self[:physics].shape.verts
		original_position = self[:physics].body.p.clone
		
		# process
			# resize backend rect with fixed aspect ratio, to get a good guess of the size
			@entity[:physics].shape.resize!(
				grab_handle, coordinate_space, point:point, lock_aspect:true,
				minimum_dimension:minimum_dimension, limit_by: :height
			)
			
			# Perform final, exactly height computation on the final tick ONLY.
			# Performing this every tick causes a lot of jitter.
			@entity.height = @entity[:physics].shape.height
			# (setting height this way allows Text to set the exact width)
		
		
		# return proc to reverse the process		
		undo = Proc.new do
			# same as for Rectangle
			self[:physics].shape.set_verts!(original_verts, CP::Vec2.new(0,0))
			self[:physics].body.p = original_position
		end
		
		return undo
	end
end