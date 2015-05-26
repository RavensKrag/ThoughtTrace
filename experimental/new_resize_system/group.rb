class Group
	def resize!(grab_handle, coordinate_space=nil, point:nil, delta:nil, minimum_dimension:1, lock_aspect:false, limit_by:nil)
		
		
		# === save values specific to this element / this level of transform
		# need these to move the sub-elements using range-remap
		original_body = self[:physics].body.clone
		
		original_width  = self[:physics].shape.width
		original_height = self[:physics].shape.height
		
		# needed for restore
		original_positions = self.collect{ |e|  e[:physics].center }
		
		
		# parent save
		original_verts    = self[:physics].shape.verts
		original_position = self[:physics].body.p.clone
		
		
		# === resize this element
		self[:physics].shape.resize!(
			grab_handle, :world_space, point:@point, lock_aspect:true,
			minimum_dimension:MINIMUM_DIMENSION
		)
		# TODO: make sure coordinate spaces check out and everything
		# NOTE: Groups can only be resized with locked aspect ratio. not quite sure how that affects things
		
		
		
		
		
		
		
		
		# === resize nested elements, and save their memos so you can undo later
		# p @group[:physics].shape.verts.collect{|v| v.to_s }
		delta = @group[:physics].shape.vert(1) - original_verts[1]
		dx = (delta.x.round + original_verts[1].x.round).to_f / original_verts[1].x.round
		dy = (delta.y.round + original_verts[1].y.round).to_f / original_verts[1].y.round
			# p [dx,dy]
			# puts [dx.abs - dy.abs]
			# yes: as expected dx and dy are almost the exact same value
			# puts delta
		# TODO: should only really compute either dx or dy
		# TODO: consider using (delta / old + 1) rather than (delta + old / old) to get dx or dy
		
		# Bounding box seems to be snapping back to wrap around the entities during resize
			# I think this is because of the code in the Group#update that says Group should always be trying to limit it's size to the extent of the BB around all member Entities
		
		rect_memos = 
			@rects.collect do |entity, original_verts|
				# resize based on original vert * percentage change of container
				p = entity[:physics].shape.vert(1) * dx
				
				# PLAN: this would handle both Rectangle and Text objects. The method would be polymorphic, and perform necessarily Text-specific calculations.
				# NOTE: this method needs to be separate from the #resize! on shape, because that is defined in terms of general rect geometry, which doesn't know about the peculiarities of Text resizing.
				entity.resize!(
					CP::Vec2.new(1,1), :local_space, point:p, lock_aspect:true,
					minimum_dimension:min
				)
				
				# NOTE: want to handle Groups with the same interface as Rectangles though, so do Groups really need a separate branch? Would the Groups branch just under the same polymorphic interface, but for Groups it would essentially trigger recursion?
				# NOTE: currently nested Groups are triggered in this branch. no separate case.
			end
		
		circle_memos = 
			@circles.each do |entity, original_radius|
				# change radius based on original radius
				# (may actually have to be based on diameter? not quite sure)
				# well, you do r * 2 * delta / 2 = new radius
				# so it's exactly the same as just using the radius
				r = entity[:physics].radius
				
				
				# PLAN: could feed a 'grab handle' parameter into this, but it would have no effect
				# circle can actually have a slightly different interface, because it uses a different backend structure with different needs
				# want the entity#resize! to have properties of convergent evolution, trying to become a similar as possible, but you don't need it be exactly the same, I think.
				entity.resize!(
					:local_space, delta:(r*dx), lock_aspect:true,
					minimum_dimension:min
				)
			end
		
		undo_memos = rect_memos + circle_memos
		
		
		
		
		
		
		
		
		
		
		
		# === reposition the sub-elements
		
		# --- map original Entity positions onto new Group coordinate space
		# specify intervals for interval remapping
		x_in  = 0..original_width
		x_out = 0..self[:physics].shape.width
		
		y_in  = 0..original_height
		y_out = 0..self[:physics].shape.height
		
		
		# examine each Entity in the Group
		positions = 
			original_positions.collect do |p|
				# position of the Entity in the Group's coordinate space
				p = original_body.world2local(p)
				
					# remap intervals to account for resize
					p.x = range_remap(value:p.x, input_range:x_in, output_range:x_out)
					p.y = range_remap(value:p.y, input_range:y_in, output_range:y_out)
				
				
				# convert back to global coordinate space
				self[:physics].body.local2world(p)
			end
		
		# apply new positions
		self.zip(positions) do |entity, p|
			center = entity[:physics].shape.center
			entity[:physics].right_hand_on_red(center, p)
		end
		
		
		
		
		
		
		
		
		
		
		undo = Proc.new do
			# undo all the sub-entity transforms
			undo_memos.each do |memo|
				memo.call
			end
			
			
			
			
			# undo transforms specific to this entity / this level
			
			
			# original_body
			# NOTE: I think 'original body' is actually only used to transform points into normalized local space? so you don't really need that, as much as you need to make sure that the shape just goes back to exactly the way it was before.
			
			# original_width 
			# original_height
			# NOTE: same for original width / height
			
			
			# original_positions
			
			
			
			# geometry reset same as rect resize action -> same as rect edit action
			self[:physics].shape.set_verts!(original_verts, CP::Vec2.new(0,0))
			self[:physics].body.p = original_position
			
			
			# moving sub-entities back to original positions is special to Group
			self.zip(original_positions) do |entity, p|
				entity[:physics].body.p = p
			end
		end
		
		return undo
	end
	
	
	
	private
	
	# NOTE: move this to a more general location. This is an extremely useful method, and will be become even more useful as we get into complex spectrum stuff.
	
	# Remap a value from the input range, to the output range.
	# If no output range is specified, will map onto the normalized range aka [0..1]
	def range_remap(input_range:0..255, output_range:0.0..1.0, value:0)
		src  = input_range
		dest = output_range
		
		# src: http://stackoverflow.com/questions/3451553/value-remapping
		# low2 + (value - low1) * (high2 - low2) / (high1 - low1)
		return dest.first + (value - src.first) * (dest.last - dest.first) / (src.last - src.first)
	end
end
