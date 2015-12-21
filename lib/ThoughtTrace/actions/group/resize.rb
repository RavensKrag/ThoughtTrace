module ThoughtTrace
	module Groups
		class Group
			module Actions


class Resize < ThoughtTrace::Rectangle::Actions::Resize
	# Entity only needed for the Rectangle 'resize', 
	# and in this case, should point to the Group itself.
	# If that can't happen, then the Group can't be a subclass of Rectangle
	initialize_with :group, :action_factory
	
	
	# called on first tick
	def press(point)
		# NOTE: undefined behavior if the elements of Group are changed while the 'edit' or 'resize' actions are active
		
		
		# TODO: this action needs recursive flow.
			# resizing a Group requires resizing elements inside the Group,
			# and sometimes those elements are themselves Groups.
			
			# but you need a 'recursive memory' so you can undo things with that same recursive structure
			
			# because of this need for 'recursive memory' in the case of an undo,
			# this action can not be easily converted back to a single method.
			# This means Groups can not be resized in quite the same way that individual Entities can.
			# This action is useful for when a human wants to resize a bunch of things quickly,
			# but instructing the system to resize things relative to each other is more complicated.
			
			
			# But I'm not yet sure how this impacts abstraction.
			# How then, would you expect to resize a Prefab, which is just a special sort of Group?
			# Maybe the Group resize method would have to wrap this action?
			# Maybe something is wrong with the structure of this action?
				# already breaking the action's encapsulation to directly set the grab handle
				# in the case of nested groups,
				# which seems to suggest a problem.
			
			# maybe there should be resize actions at the Entity level that return mementos for undo?
				# this would solve the problem of code duplication with the special Text resize as well
		
		
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
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		super(point)
		undo()
		# TODO: consider trying to get rid of this UNDO here
		# NOTE: without it, there's currently a lot of jitter / drift because of the automatic resizing happening in Group#update
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		min = 10
		
		# NOTE: Group update resizes the rectangle, which can cause jitter and other problems when that resizing intersects with the resizing happening in this action.
		
		
		# TODO: should be calling a Entity-specific resize method, so like, Text can use the "exact dimension resize" logic currently seen in the Text resize action.
		# TODO: make sure this works with n-level nested groups
		
		
		# NOTE: you must limit the rescaling of the group such that you do not scale any member below it's minimum size. If you do not, then you will get distortion.
		
		# === resize all entities
		# TODO: should only really compute either dx or dy
		# TODO: consider using (delta / old + 1) rather than (delta + old / old) to get dx or dy
		
		
		@memo = @entity.resize!(
			@grab_handle, :world_space, point:@point,
			minimum_dimension:1, lock_aspect:true, limit_by: :smaller
		)
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		# reset group position AND geometry
		@memo.call() if @memo # memo will reset all member entities, which includes nested groups
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
end



end
end
end
end