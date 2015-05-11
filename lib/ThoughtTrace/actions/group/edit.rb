module ThoughtTrace
	module Groups
		class Group
			module Actions


class Edit < ThoughtTrace::Rectangle::Actions::Edit
	# Entity only needed for the Rectangle 'resize', 
	# and in this case, should point to the Group itself.
	# If that can't happen, then the Group can't be a subclass of Rectangle
	initialize_with :group, :action_factory
	
	
	# called on first tick
	def press(point)
		# NOTE: undefined behavior if the elements of Group are changed while the 'edit' or 'resize' actions are active
		
		
		
		
		# NOTE: this action needs to be called when clicking on the bounding box around the entire Group, not simply when clicking on some element within the group. You need to see the bounding box for this to make sense.
		

	# + group BB => rectangle A
	# + for each element in group, convert position into normalized (0..1) coordinate space of A
	# + resize A into rectangle B
	# + take normalized positions in space of A, convert them to normalized positions in space of B
	# + convert normalized positions in space of B into standard coordinates relative to B
	# + convert standard coordinates in space of B into global coordinates
	# + assign these new global coordinates to each and every element of the group
		
		
		# NOTE: save original positions of Entities for restoration during Undo phase
		# NOTE: maybe need to save the Geometry of the Entities as well? Maybe delegate to individual resize actions?
		
		# NOTE: remember that the group resize will always be done with locked aspect ratio (I think only Rectangle can be resized WITHOUT locking the ratio, and that is done as a separate action called Rectangle 'edit')
		@entity = @group # set 'entity' variable so the Rect action can move the Group container
		super(point)
		
		
		
		@original_body = @group[:physics].body.clone
		
		@original_width  = @group[:physics].shape.width
		@original_height = @group[:physics].shape.height
		
		
		
		@original_positions = @group.collect{ |e|  e[:physics].center }
		@member_vert_data   = @group.collect do |e|
			shape = e[:physics].shape
			if shape.is_a? CP::Shape::Poly
				shape.verts
			else
				shape.radius
			end
		end
		
		
		# split collection by type
		collection = @group.zip(@member_vert_data)
		@rects   = collection.select{ |a,b| a.is_a? ThoughtTrace::Rectangle      }
		@texts   = collection.select{ |a,b| a.is_a? ThoughtTrace::Text           }
		@circles = collection.select{ |a,b| a.is_a? ThoughtTrace::Circle         }
		@groups  = collection.select{ |a,b| a.is_a? ThoughtTrace::Groups::Group  }
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		super(point)
		undo()
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		min = 10
		# === resize the group's bounding shape
		# super()
		@entity[:physics].shape.resize!(
			@grab_handle, :world_space, point:@point, lock_aspect:true,
			minimum_dimension:min
		)
		
		
		
		# NOTE: Group update resizes the rectangle, which can cause jitter and other problems when that resizing intersects with the resizing happening in this action.
		
		
		# TODO: should be calling a Entity-specific resize method, so like, Text can use the "exact dimension resize" logic currently seen in the Text resize action.
		# TODO: make this worth with circles as well
		# TODO: make sure this works with n-level nested groups
		
		
		# NOTE: you must limit the rescaling of the group such that you do not scale any member below it's minimum size. If you do not, then you will get distortion.
		
		# === resize all entities
		# p @group[:physics].shape.verts.collect{|v| v.to_s }
		delta = @group[:physics].shape.vert(1) - @original_verts[1]
		dx = (delta.x.round + @original_verts[1].x.round).to_f / @original_verts[1].x.round
		dy = (delta.y.round + @original_verts[1].y.round).to_f / @original_verts[1].y.round
			# p [dx,dy]
			# puts [dx.abs - dy.abs]
			# yes: as expected dx and dy are almost the exact same value
			# puts delta
		
		
		
		
		# NOTE: this may have problems, because Text is a Rectangle
		# NOTE: beware of possibility of nested groups (maybe this case includes prefabs?)
		
		@rects.each do |entity, original_verts|
			# resize based on original vert * percentage change of container
			p = original_verts[1] * dx
			
			entity[:physics].shape.resize!(
				CP::Vec2.new(1,1), :local_space, point:p, lock_aspect:true,
				minimum_dimension:min
			)
		end
		
		@texts.each do |entity, original_verts|
			# resize like rect, assuming locked aspect ratio,
			# and then again in text-specific way to lock exact size
			# (same logic as Text resize action)
			
			# NOTE: all Text objects also go through processing as Rectangles
			entity.height = entity[:physics].shape.height
			
			# like in text resize action, you can move this to the release phase to reduce jitter,
			# but because we're editing multiple text objects here,
			# it may be better just to see the jitter, even though it's unsettling,
			# because it will show the reality of the data?
		end
		
		@circles.each do |entity, original_radius|
			# change radius based on original radius
			# (may actually have to be based on diameter? not quite sure)
			# well, you do r * 2 * delta / 2 = new radius
			# so it's exactly the same as just using the radius
			entity[:physics].shape.set_radius!(original_radius * dx)
		end
		
		@groups.each do |entity, original_verts|
			# groups will also get processed as rectangles, because Group < Rectangle
		end
		
		
		
		
		
		# Bounding box seems to be snapping back to wrap around the entities during resize
			# I think this is because of the code in the Group#update that says Group should always be trying to limit it's size to the extent of the BB around all member Entities
		
		# === map original Entity positions onto new Group coordinate space
		# specify intervals for interval remapping
		x_in  = 0..@original_width
		x_out = 0..@group[:physics].shape.width
		
		y_in  = 0..@original_height
		y_out = 0..@group[:physics].shape.height
		
		
		# examine each Entity in the Group
		positions = 
			@original_positions.collect do |p|
				# position of the Entity in the Group's coordinate space
				p = @original_body.world2local(p)
				
					# remap intervals to account for resize
					p.x = range_remap(value:p.x, input_range:x_in, output_range:x_out)
					p.y = range_remap(value:p.y, input_range:y_in, output_range:y_out)
				
				
				# convert back to global coordinate space
				@group[:physics].body.local2world(p)
			end
		
		# apply new positions
		@group.zip(positions) do |entity, p|
			center = entity[:physics].shape.center
			entity[:physics].right_hand_on_red(center, p)
		end
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		# reset group position AND geometry
		super()
		
		
		# reset member entity positions
		@group.each_with_index do |entity, i|
			p = @original_positions[i]
			entity[:physics].body.p = p
		end
		
		
		# reset member entity geometry
		offset = CP::Vec2.new(0,0)
		@rects.each do |entity, verts|
			entity[:physics].shape.set_verts!(verts, offset)
		end
		
		@circles.each do |entity, original_radius|
			entity[:physics].shape.set_radius!(original_radius)
		end
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		super(point)
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		super(point)
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		super()
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



end
end
end
end