# click on Entity A, and drag to Entity B

module ThoughtTrace
	class Entity
		module Actions


class SpawnConstraint < ThoughtTrace::Actions::BaseAction
	initialize_with :entity, :space
	
	
	# called on first tick
	def press(point)
		# should just select a Constraint and a Visualization from already declared objects
		# but how does that list get made?
		# and then how do you access those lists?
		
		constraint = ThoughtTrace::Constraints::LimitHeight.new
		visualization = ThoughtTrace::Constraints::Visualizations::DrawEdge.new
		
		
		# TODO: use the 'easy package create / remove API' to generate this new package
		package = ThoughtTrace::Constraints::Package.new(constraint, visualization)
		marker_a = package.marker_a
		
		# put marker A down at this point, so that it will bind to this Entity
		# (actually, need to bind it here, as binding is part of the Move action, but you're bypassing that right now)
		# move marker B, with the move marker action
		
		# TODO: chain into move marker
		# TODO: figure out if actions should be able to request the ActionFactory. Would be much easier to create helper actions that way.
		@move_action = ThoughtTrace::Constraints::Marker::Actions::Move.new(marker_a, @space)
		@move_action.press(point)
		
		# NOTE: binding only one marker may cause the Package to constantly call @pair.unbind
		# really need to double check that, when you try to implement this thing
		# (this note was copied from the "easy bind" function sketch)
		
		
		@start = point # need to save in case of redo
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		@move_action.update(point)
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@move_action.apply
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		entity_b = @space.point_query_best(point)
		
		
		if entity_b.nil?
			# "short circuit" if there is no B (ie, released in empty space)
			# (note that this allows for self-loops, which is actually kinda nice)
			
			self.cancel # cancel is based on #undo
		else
			# commit the creation
			
			
			# bind entities as appropriate
			# package.pair.bind(entity_a, entity_b)
				# no need to do this:
				# when the markers are released, they will bind to Entities
				# when the Package is updated, it will propagate those entities into the Pair
			# add the package to the collection		
			
			
			
			
			# NOTE: the 'release' method of the Marker Move action will bind B, and A was bound in 'press' from this action. Thus, you only need to delegate to the move Action, and this is completed. Don't have to directly interface with the package.
			@move_action.release(point)
			
			@end = point # needed for in case of redo
		end
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		# revert all changes made by the Package
		# NOTE: would be nice to revert the changes made by the constraint, but I'm not sure how that would happen. Though, if you can't, then the undo will get rather weird. This Action will not undo cleanly.
		
		
		
		# cancel the creation action
		# - delete marker a
		# - delete marker b
		# - delete constraint
		# - delete visualization
		# - delete package
		
		
		# don't really need to undo the move, because the whole Package is being deleted
		# (including the marker that was moved)
		
		# TODO: need 'interface to easily remove a Package' to remove the Package with
		
		# remove the package from the collection
		@package
	end
	
	def redo
		self.press(@start) # side effect: @start = @start, which does nothing (it's weird)
		# @move_action.press(@start) # calling #press again already triggers this call
		@move_action.hold(@start)
		@move_action.hold(@end)
		@move_action.release(@end)
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