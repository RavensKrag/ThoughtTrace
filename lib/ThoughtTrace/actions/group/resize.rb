module ThoughtTrace
	module Groups
		class Group
			module Actions


class Resize < ThoughtTrace::Actions::BaseAction
	initialize_with :selection, :action_factory
	
	
	# called on first tick
	def press(point)
		@origin = point
		
		# can't just use the :entity, because that would give the single item clicked on, and not the entire Group
		@group = @selection
		
		
		
	# + group BB => rectangle A
	# + for each element in group, convert position into normalized (0..1) coordinate space of A
	# + resize A into rectangle B
	# + take normalized positions in space of A, convert them to normalized positions in space of B
	# + convert normalized positions in space of B into standard coordinates relative to B
	# + convert standard coordinates in space of B into global coordinates
	# + assign these new global coordinates to each and every element of the group
		
		
		
		# NOTE: this action needs to be called when clicking on the bounding box around the entire Group, not simply when clicking on some element within the group. You need to see the bounding box for this to make sense.
		
		
		
		bb = @group.collect{|x|  x[:physics].shape.bb }.reduce(&:merge)
		@rect_a = bb.to_rectangle
		# @group.collect{|x|  x[:physics] }
		
		@resize = @action_factory.create(@rect_a, :resize) # resize with aspect ratio lock
		@resize.press(point)
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		@resize.press(point)
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@resize.apply
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@resize.undo
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		@resize.release(point)
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		@rect_a.draw
	end
end



end
end
end
end