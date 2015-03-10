
# basic forward flow:
# create UI entity
# connect UI entity to Text
# add UI entity to space

# manipulate UI entity to adjust which part of the substring are selected
	# manipulations build on standard entity actions, like Move or Resize
# act on UI entity to seal the transform
	# ex) moving the UI entity out of the Text hitbox would trigger Split, splintering off a piece of the Text object into a new Text object
# (requires manipulation of the text object from the UI entity)
# (which is why it was passed in earlier)






# pretty much don't need this any more,
# considering how little boilerplate is required for new Action format

module ThoughtTrace
	class Text
		module Actions


class Split < Entity::Actions::Action
	initialize_with :entity, :space
	
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
		@ui_entity = ActionUI.new @entity
		@space.entities.add @ui_entity
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@space.entities.delete @ui_entity
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











class ActionUI < Entity
	def initialize
		
	end
	
	
	
	module Actions
		


		class Foo < Entity::Actions::Action
			initialize_with :foo, :baz, :bar
			
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

	

