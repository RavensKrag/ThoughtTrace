class Text < Rectangle
	def resize!(grab_handle, coordinate_space=nil, point:nil, delta:nil, minimum_dimension:1)
		
		# save
			# should be the same as Rectangle entity
		original_verts    = self[:physics].shape.verts
		original_position = self[:physics].body.p.clone
		
		# process
			# === THIS IS THE OLD GLITCHY WAY
			# resize backend rect with fixed aspect ratio, to get a good guess of the size
			@entity[:physics].shape.resize!(
				grab_handle, coordinate_space, point:point, lock_aspect:true,
				minimum_dimension:minimum_dimension, limit_by: :height
			)
			
			# Perform final, exactly height computation on the final tick ONLY.
			# Performing this every tick causes a lot of jitter.
			@entity.height = @entity[:physics].shape.height
			# (setting height this way allows Text to set the exact width)
			
			
			
			
			# === TRY THIS WAY INSTEAD
			# prep for counter-steering
			countersteer_handle = grab_handle * -1
			x = countersteer_handle.to_a
			type, target_indidies = CP::Shape::Rect::VEC_TO_TRANSFORM_DATA[x]
			
			
			local_anchor = 
				case type
					when :edge
						target_indidies
							.collect{  |i|    @components[:physics].shape.vert(i)    }
							.reduce{   |a,b|  CP::Vec2.midpoint(a,b)                 }
					when :vert
						i = target_indidies.first
						@components[:physics].shape.vert(i)
				end
			
			anchor = @components[:physics].body.local2world(local_anchor)
			
			
			# set width and height
			type, target_indidies = CP::Shape::Rect::VEC_TO_TRANSFORM_DATA[grab_handle.to_a]
			
			origin =
				case type
					when :edge
						target_indidies
							.collect{  |i|    @components[:physics].shape.vert(i)    }
							.reduce{   |a,b|  CP::Vec2.midpoint(a,b)                 }
					when :vert
						i = target_indidies.first
						@components[:physics].shape.vert(i)
				end
			
			d = point - origin
			dh = d.y
			dh *= -1 if grab_handle.y < 0
			height = self.height + d.y
			
			
			h = [height, minimum_dimension].max
			w = @font.width(@string, height)
			
			grab_handle = CP::Vec2.new(1,1)
			point       = CP::Vec2.new(w,h)
			@components[:physics].shape.resize!(
				grab_handle, :local_space, point:point, lock_aspect:false
			)
			
			# counter-steer
			@components[:physics].right_hand_on_red(local_anchor, anchor)
			
			
			
		
		
		# return proc to reverse the process	
		undo = Proc.new do
			# same as for Rectangle
			@components[:physics].shape.set_verts!(original_verts, CP::Vec2.new(0,0))
			@components[:physics].body.p = original_position
		end
		
		return undo
	end
end