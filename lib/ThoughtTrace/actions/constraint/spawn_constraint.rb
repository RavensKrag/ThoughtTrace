# click on Entity A, and drag to Entity B

module ThoughtTrace
	class Entity
		module Actions


class SpawnConstraint < ThoughtTrace::Actions::BaseAction
	initialize_with :entity, :space, :action_factory, :document
	
	
	# called on first tick
	def press(point)
		# should just select a Constraint and a Visualization from already declared objects
		# but how does that list get made?
		# and then how do you access those lists?
		
		constraint = ThoughtTrace::Constraints::LimitHeight.new
		visualization = ThoughtTrace::Constraints::Visualizations::DrawEdge.new
		# TODO: use the 'easy package create / remove API' to generate this new package
		@package = ThoughtTrace::Constraints::Package.new(constraint, visualization)
		
		
		
		# put marker A down at this point, so that it will bind to this Entity
		# (actually, need to bind it here, as binding is part of the Move action, but you're bypassing that right now)
		target_a = @entity
		@package.marker_a.bind_to(target_a)
		
		
		
		
		
		
		
		# move marker B, with the move marker action
		marker = @package.marker_b
		
		# initial place marker at the current position of the cursor
		marker[:physics].body.p = point.clone
		
		@move_action = @action_factory.baz(
							marker, :move, typecast_type:ThoughtTrace::Entity
						)
						# use standard Entity move for now
						
		@move_action.press(point)
		
		# NOTE: binding only one marker may cause the Package to constantly call @pair.unbind
		# really need to double check that, when you try to implement this thing
		# (this note was copied from the "easy bind" function sketch)
		
		
		@start_point = point # need to save in case of redo
	end
	
	def hold(point)
		@move_action.update(point)
		@move_action.apply
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	# DO NOT FINALIZE EFFECTS HERE, only finish preliminary calculations
	def release(point)
		@package.marker_b
		
		target_b = @action_factory.determine_target(@document, point, ThoughtTrace::Entity)
		puts target_b
		# may have to change #determine_target such that you can ban certain types.
		# Want to avoid trying to attach the marker to another marker or something
		
			# but wait,
			# what happens when you attach multiple constraints to the same Entity?
			# how does the user see / pick up a particular marker?
			# (probably want markers to drift from center a bit, in the direction of the line)
			# consider: number of markers, marker radius, angle of each marker with the center
		
		# At this moment, this is only not an error because the contents of Package do not live in the Space
		
		# NOTE: currently hardcoding an override for Package z index in Package#draw
		
		
		
		
		if entity_b.nil?
			# "short circuit" if there is no B (ie, released in empty space)
			# (note that this allows for self-loops, which is actually kinda nice)
			# except will need to figure out how to actually visualize self-loops
			
			self.cancel # cancel is based on #undo
		else
			# commit the creation
			
			# The 'release' method of the Marker Move action will bind B,
			# and A was bound in 'press' from this action.
			# Thus, you only need to delegate to the move Action, and this is completed.
			@move_action.release(point)
			
			@package.marker_b.bind_to(target_b)
			
			@end_point = point # needed for in case of redo
		end
	end
	
	
	
	
	# transition from neutral to forward
	# not quite like the apply method found in other Action types
	# this is only called once on release, and on redo
	# (may not end up actually needing this method)
	def apply
		# add package to space
			# add marker_a
			# add marker_b
		
		# NOTE: actions like this are a big potential source of memory leaks, because of hanging on to Package objects etc that are no longer in the space.
		# ie) Package was later removed, but a reference is still held by an instance of this class
		# as long as this Action remains in the history, the reference can not be freed.
		# may also effect Entity objects bound up in the constraint, etc
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
		self.press(@start_point)
		# side effect: @start_point = @start_point, which does nothing (it's weird)
		# @move_action.press(@start_point) # calling #press again already triggers this call
		@move_action.hold(@start_point)
		@move_action.hold(@end)
		@move_action.release(@end)
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		@package.marker_a.update
		@package.marker_b.update
		
		z = 10000
		@package.marker_a.draw(z)
		@package.marker_b.draw(z)
		
		@package.update
		@package.draw(@space)
	end
end



end
end
end