module ThoughtTrace
	module Actions


class BaseAction
	# TODO: default initializer defined in BaseAction should accept one argument, "target"
		# is this actually necessary?
		# would it be better for all actions to specify every possible argument in their type list?
	
	class << self
		def argument_type_list
			@type_list
		end
		
		
		private
		
		
		
		# metaprogrraming method
			# defines #initialize to set specified values
			# defines list of variable types, so Action creation system knows what to feed class on #init
		# 
		# needs to be meta level
		# + so it kinda feels like something in between #initialize and #attr_accessors
		# + so that the argument type list will be stored on the class
		# 
		# 
		# example method call
		# initialize_with :space, :selection, :text_input, :clone_factory, :target
		def initialize_with(*arg_names)
			# create the initializer to accept the variables as named,
			# and place them in instance variables with similar names
			# ex) @space = space
			define_method :initialize do |*args|
				assoc_list = arg_names.zip args
				assoc_list.each do |name, value|
					instance_variable_set "@#{name}", value
				end
			end
			
			# store list of argument names on the BaseAction class
			# as a class instance variable
			@type_list = arg_names
		end
	end
	
	
	
	
	
	# similar to Object#nil?
	# not very useful for this class, but very useful for descendant classes
	def null_action?
		return self.is_a? ThoughtTrace::Actions::NullAction
	end
	
	
	
	
	
	
	
	
	
	
	# NOTE: none of these methods should have returns. all data should be juggled between parts by taking advantage of the internal state tracking mechanisms of the object.
	
	
	
	# ===
	# These methods should not be overridden by child classes.
	# They exist only as conveniences to external systems,
	# not for defining core internal behavior.
	# ---
	def hold(point)
		update(point)
		apply()
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
	
	
	
	
	
	# ========================
	# The following methods should be defined in every Action class,
	# even if they have to be stubbed
	
	
	# called on first tick
	def press(point)
		
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		
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
	
end



end
end