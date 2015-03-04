# sketch: new action structure

class Move < Action
	def initialize(target)
		@target = target
	end
	
	
	
	
	# NOTE: removal of Memento collapses the Action, removing the need for separate "inner" and "outer" APIs
	
	
	# NOTE: none of these methods should have returns. all data should be juggled between parts by taking advantage of the internal state tracking mechanisms of the object.
	
	
	
	def hold(point)
		update(point)
		apply()
		update_visualization(point)
	end
	
	def cancel
		self.undo()
		# NOTE: when an action is canceled, it should probably be removed from the undo stack. But that's not something that should happen inside the Action class.
	end
	
	
	
	
	
	
	
	
	
	
	
	# called on first tick
	def press(point)
		# mark the initial point for reference
		@origin = point
		@start = @target[:physics].body.p.clone
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		# move relative to the initial point
		delta = point - @origin
		@destination = @start + delta
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@target[:physics].body.p = @destination
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@target[:physics].body.p = @start
	end
	
	# changed my mind about undo-ing
	# apply the originally intended transformation to the data
	def redo
		self.apply()
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
	def draw_visualization
		
	end
end