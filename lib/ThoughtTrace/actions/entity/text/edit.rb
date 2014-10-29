module ThoughtTrace
	class Text
		module Actions


class Edit < Entity::Actions::Action
	initialize_with :text_input, :clone_factory, :entity
	
	# called on first tick
	def setup(point)
		return @text_input, @clone_factory
	end
	
	# called each tick
	def update(point)
		return point
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
			text_input, clone_factory = @initial
			point = @future
			
			
			text_input.add @entity, @entity.nearest_character_boundary(point)
			
			
			# NOTE: Can't move prototype registration into TextInput because you would have no way to step back from that transformation in this Action.
			# TODO: Figure out how to move prototype registration into TextInput, rather than this one action.
			@old_prototype = clone_factory.make ThoughtTrace::Text
			clone_factory.register_prototype @entity
		end
		
		# set past state
		def reverse
			text_input, clone_factory = @initial
			point = @future
			
			text_input.clear
			clone_factory.register_prototype @old_prototype
		end
	end
end



end
end
end