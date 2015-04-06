module ThoughtTrace
	module Groups
		class Group
			module Actions


class Edit < ThoughtTrace::Actions::BaseAction
	# Entity only needed for the Rectangle 'resize', 
	# and in this case, should point to the Group itself.
	# If that can't happen, then the Group can't be a subclass of Rectangle
	initialize_with :selection, :action_factory
	
	
	# called on first tick
	def press(point)
		@origin = point
		
		# can't just use the :entity, because that would give the single item clicked on, and not the entire Group
		@group = @selection
		
		
		# NOTE: undefined behavior if the elements of Group are changed while the 'edit' or 'resize' actions are active
		
		
		
		
		# NOTE: this action needs to be called when clicking on the bounding box around the entire Group, not simply when clicking on some element within the group. You need to see the bounding box for this to make sense.
		
		
		# NOTE: Group itself can not be a Rectangle, because
		# 1) symbol collision of instance variables between this action and the 'parent' action
			# If the Group is a Rectangle, then super MUST be used to call the parent action, as using the ActionFactory will trigger an infinite loop while trying to resolve the Action name => Action object
		# 2) Rectangle resize requires a pointer to the 'Entity', but that would have to be this object (less compelling reason, and actually probably wouldn't involve changes)
		
		
		# WAIT. maybe it's not a big deal? maybe @original_width and @original_height were going to be the same anyway?
		# If that's all there is to the symbol collision consider collapsing the actions again.
		
		# ( Really don't like having to call @group.rect, is all )


	# + group BB => rectangle A
	# + for each element in group, convert position into normalized (0..1) coordinate space of A
	# + resize A into rectangle B
	# + take normalized positions in space of A, convert them to normalized positions in space of B
	# + convert normalized positions in space of B into standard coordinates relative to B
	# + convert standard coordinates in space of B into global coordinates
	# + assign these new global coordinates to each and every element of the group
		
		@original_width  = @group.rect[:physics].shape.width
		@original_height = @group.rect[:physics].shape.height
		
		
		@rect_resize = @action_factory.create(@group.rect, :resize)
		
		@rect_resize.press(point)
		
		# NOTE: save original positions of Entities for restoration during Undo phase
		# NOTE: maybe need to save the Geometry of the Entities as well? Maybe delegate to individual resize actions?
		
		# NOTE: remember that the group resize will always be done with locked aspect ratio (I think only Rectangle can be resized WITHOUT locking the ratio, and that is done as a separate action called Rectangle 'edit')
		
		@original_positions = @group.collect{ |e|  e[:physics].body.p.clone }
		@original_body = @group.rect[:physics].body.clone
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		# === resize the group's bounding shape
		@rect_resize.update(point)
		
		
		
		# === map original Entity positions onto new Group coordinate space
		# specify intervals for interval remapping
		x_in  = 0..@original_width
		x_out = 0..@group.rect[:physics].shape.width
		
		y_in  = 0..@original_height
		y_out = 0..@group.rect[:physics].shape.height
		
		
		# examine each Entity in the Group
		@group.each_with_index do |entity, i|
			# position of the Entity in the Group's coordinate space
			p = @original_positions[i].clone # clone is unnecessary if world2local returns new vec
			p = @original_body.world2local(p)
			
			
				# remap intervals to account for resize
				p.x = range_remap(value:p.x, input_range:x_in, output_range:x_out)
				p.y = range_remap(value:p.y, input_range:y_in, output_range:y_out)
			
			
			# convert back to global coordinate space
			p = @group.rect[:physics].body.local2world(p)
			
			
			
			# set new body position
			entity[:physics].body.p = p
		end
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@rect_resize.apply
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@rect_resize.undo
		
		@group.each_with_index do |entity, i|
			p = @original_positions[i]
			entity[:physics].body.p = p
		end
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		@rect_resize.release(point)
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		@rect_resize.update_visualization(point)
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		@rect_resize.draw
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