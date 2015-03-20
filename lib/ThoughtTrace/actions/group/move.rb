module ThoughtTrace
	module Groups
		class Group
			module Actions


class Move < ThoughtTrace::Actions::BaseAction
	initialize_with :selection, :action_factory
	
	
	# called on first tick
	def press(point)
		# can't just use the :entity, because that would give the single item clicked on, and not the entire Group
		@group = @selection
		
		@helpers = Array.new(@group.size)
		@group.each_with_index do |x, i|
			@helpers[i] = @action_factory.create(x, :move)
			# this creates infinite recursion,
			# because the Factory is retrieving the Group Action for each Entity,
			# rather than the Action specific to that Entity type
		end
		
		@helpers.each{ |x|  x.press(point)  }
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		@helpers.each{ |x|  x.update(point)  }
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@helpers.each{ |x|  x.apply  }
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@helpers.each{ |x|  x.undo  }
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
end
end