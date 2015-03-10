# Base for actions that only need to fire once, rather than updating every frame.

module ThoughtTrace
	module Actions


class OneShotAction < BaseAction
	# don't declare the initialize here, as this is still an abstract class
	
	
	
	# ===
	# These methods should not be overridden by child classes.
	# They exist only as conveniences to external systems,
	# not for defining core internal behavior.
	# ---
	
	# press is defined in the core for multi-tick actions,
	# but for one-shots you define 'setup' instead
	def press(point)
		setup(point)
		apply
	end
	
	
	
	def hold(point)
		update(point)
		update_visualization(point)
	end
	
	def cancel
		self.undo()
		# NOTE: when an action is canceled, it should probably be removed from the undo stack. But that's not something that should happen inside the Action class.
	end
	
	# changed my mind about undo-ing
	# apply the originally intended transformation to the data
	def redo
		self.apply()
	end
	
	# ===
	
	
	
	
	
	# Called on the first tick. Prepare the transform.
	def setup(point)
		
	end
	
	# Called on the first tick. Applies the transform
	def apply
		
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		
	end
end



end
end