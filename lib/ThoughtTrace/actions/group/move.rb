module ThoughtTrace
	module Groups
		class Group
			module Actions


class Move < ThoughtTrace::Actions::BaseAction
	initialize_with :group, :action_factory
	
	
	# called on first tick
	def press(point)
		@origin = point
		
		
		@start_points = Array.new(@group.size)
		@end_points   = Array.new(@group.size)
		@group.each_with_index do |x, i|
			@start_points[i] = x[:physics].body.p.clone
		end
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		delta = movement_delta(point)
		
		@group.size.times do |i|
			@end_points[i] = @start_points[i] + delta
		end
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@group.each_with_index do |x,i|
			x[:physics].body.p = @end_points[i]
		end
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@group.each_with_index do |x,i|
			x[:physics].body.p = @start_points[i]
		end
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		
	end
	
	
	private
	
	def movement_delta(point)
		return point - @origin
	end
end



end
end
end
end