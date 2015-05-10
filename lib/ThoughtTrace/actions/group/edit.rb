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
		# NOTE: Group has been made into a subclass of Rectangle, so many things will have to change
			# but also, the way Groups are being picked out of the space is changing,
			# so many of the assumptions in this document will change anyway
		
		
		
		
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
		@entity = @group
		super(point)
		
		
		
		@original_body = @group[:physics].body.clone
		
		@original_width  = @group[:physics].shape.width
		@original_height = @group[:physics].shape.height
		
		
		
		@original_positions = @group.collect{ |e|  e[:physics].center }
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		super(point)
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		# === resize the group's bounding shape
		super()
		# @entity[:physics].shape.resize!(
		# 	@grab_handle, :world_space, point:@point, lock_aspect:false,
		# 	minimum_dimension:MINIMUM_DIMENSION
		# )
		
		
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
		@group.each.to_a.zip(positions) do |entity, p|
			center = entity[:physics].shape.center
			entity[:physics].right_hand_on_red(center, p)
		end
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		super()
		
		@group.each_with_index do |entity, i|
			p = @original_positions[i]
			entity[:physics].body.p = p
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