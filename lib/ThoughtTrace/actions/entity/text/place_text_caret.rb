module ThoughtTrace
	class Text
		module Actions


class PlaceTextCaret < ThoughtTrace::Actions::BaseAction
	initialize_with :text_input, :clone_factory, :entity
	
	# called on first tick
	def press(point)
		@point = point
		
		@done = false
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
		unless @done
			@text_input.add @entity, @entity.nearest_character_boundary(@point)
			
			
			# NOTE: Can't move prototype registration into TextInput because you would have no way to step back from that transformation in this Action.
			# TODO: Figure out how to move prototype registration into TextInput, rather than this one action.
			@old_prototype = @clone_factory.make ThoughtTrace::Text
			@clone_factory.register_prototype @entity
		end
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@text_input.clear
		@clone_factory.register_prototype @old_prototype
		
		@done = false
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