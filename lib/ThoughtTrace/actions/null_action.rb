module ThoughtTrace
	module Actions


# Stubs out all required callbacks
# doesn't actually descend from any sort of Action,
# but you should be coding based on interface anyway
class NullAction < BaseAction
	initialize_with :entity
	
	alias :old_init :initialize
	def initialize(*args)
		old_init(*args)
		
		if @entity.nil?
			@entity = '<NIL>'
		end
	end
	
	
	
	# called on first tick
	def press(point)
		puts "#{@entity} -> setup null "
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		puts "#{@entity} -> update null"
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		puts "#{@entity} -> apply null"
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		puts "#{@entity} -> undo null"
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		puts "#{@entity} -> release null"
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