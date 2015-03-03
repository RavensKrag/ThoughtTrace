module ThoughtTrace
	module Constraints


class Marker
	module Actions


class Move < ThoughtTrace::Entity::Actions::Move
	@type_list = Entity::Actions::Move.argument_type_list
	# by creating a child class of an action, you inherit the initializer, but not the type list
	
	initialize_with :entity, :space
	
	
	# called on first tick
	def setup(point)
		super(point)
	end
	
	# called each tick
	def update(point)
		# move relative to the initial point
		current = super(point)
		
		marker = @entity
		
		target = @space.point_query_best(point, exclude:[marker])
		
		# need to make sure that the mouse and the Marker are in the same position,
		# and that there is another potential target other than the Marker
		if target
			marker.bind_to target
		else
			# unbind not yet implemented. uncommenting this will cause an exception to be thrown
			# marker.unbind
		end
		
		# NOTE: currently using the point where the mouse is to bind the marker, so that the object that would be selected by mouseover, or selection, or other such methods is the same object that would be bound. HOWEVER, consider using the center of the marker instead, as that may make more sense. Or maybe, the marker should be moved such that it's center is always on the cursor? Some combination of those ideas? Certainly something to think about.
		
		
		
		return current
	end
	
	# not often used, but you can define this callback if you need it
	# really, just added for completeness
	def cleanup(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw(point)
		
	end
	
	
	
	
	# perform the transformation here
	# by encapsulating the transform in this object,
	# it becomes easy to redo / undo actions as necessary
	ParentMemento = self.superclass.const_get 'Memento'
	class Memento < ParentMemento
		# set future state
		def forward
			super()
		end
		
		# set past state
		def reverse
			super()
		end
	end
end



end
end



end
end
