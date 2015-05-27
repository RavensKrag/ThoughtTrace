class Text < Rectangle
	def resize!(grab_handle, coordinate_space=nil, point:nil, delta:nil, minimum_dimension:1)
		
		# save
			# should be the same as Rectangle entity
		original_verts    = self[:physics].shape.verts
		original_position = self[:physics].body.p.clone
		
		# process
		counter_steer_anchor = ->(grab_handle){
			countersteer_handle = grab_handle * -1
			x = countersteer_handle.to_a
			type, target_indidies = CP::Shape::Rect::VEC_TO_TRANSFORM_DATA[x]
			
			
			local_anchor = 
				case type
					when :edge
						target_indidies
							.collect{  |i|    @entity[:physics].shape.vert(i)    }
							.reduce{   |a,b|  CP::Vec2.midpoint(a,b)                 }
					when :vert
						i = target_indidies.first
						@entity[:physics].shape.vert(i)
					else
						return # short-circuit when you attempt to use action on center
				end
			
			return local_anchor
		}
		
		
		
		
		# === prep for counter-steering
		local_anchor = counter_steer_anchor[@grab_handle]
		return unless local_anchor
		anchor = @entity[:physics].body.local2world(local_anchor)
		
		
		# === set width and height
		# resize the hitbox, and use that to figure out what the final height should be
		# (but going to resize and re-position AGAIN before final render, so no one will see this)
		@entity[:physics].shape.resize!(
			@grab_handle, :world_space, point:@point, lock_aspect:true,
			minimum_dimension:MINIMUM_FONT_HEIGHT, limit_by: :height
		)
		
		height = @entity[:physics].shape.height
		
		# It doesn't feel like you're dragging along the diagonal, as with Rectangle resize.
		# It feels like you're just resizing the width, and then the height changes to match
		# (older Text resize code actually did that, and both old and new have the same behavior)
		# But this new code can be written in terms of scaling to a specific point,
		# where as the old one could only be written in terms of deltas.
		
		
		
		# NOTE: it's important to remember that when specifying a width, you can't always get the width you want. The height of the font, the font face, and the number / type of characters in the string constrain what widths are possible.
		
		
		height = height.round # rounding needs to happen somewhere to prevent jitter. this works.
		# In addition to jitter, it is possible for the hitbox to be sized narrower than the text,
		# which is very very odd.
		
		
		# NOTE: need to set height again to apply rounding.
		h = height
		# puts h
		w = @entity.font.width(@entity.string, h)
		# puts w
		
		grab_handle = CP::Vec2.new(1,1)
		point       = CP::Vec2.new(w,h)
		
		@entity[:physics].shape.resize!(
			grab_handle, :local_space, point:point, lock_aspect:false
		)
		
		
		
		# === counter-steer
		local_anchor = counter_steer_anchor[@grab_handle]
		@entity[:physics].right_hand_on_red(local_anchor, anchor)
			# NOTE: what you really want is to save the local anchor in normalized space, so that you can use the exact same anchor twice. but that still requires the computer to calculate what the local anchor is in NEW non-normalized space. So even though that would be more humanistic, it may be worse for performance. (also floating point errors)
			
			
			
		
		
		# return proc to reverse the process	
		undo = Proc.new do
			# same as for Rectangle
			@components[:physics].shape.set_verts!(original_verts, CP::Vec2.new(0,0))
			@components[:physics].body.p = original_position
		end
		
		return undo
	end
end