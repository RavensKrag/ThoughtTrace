module ThoughtTrace
	module Actions
		module EmptySpace
			module Actions


class SpawnText < ThoughtTrace::Actions::BaseAction
	initialize_with :clone_factory, :space, :text_input
	
	# called on first tick
	def setup(point)
		# TODO: new Text should have the same size, font, etc as the last Text object accessed. ie, user should be able to create multiple similar Text objects in succession, without having to rely on the default font
		text = @clone_factory.make ThoughtTrace::Text
		text[:physics].body.p = point
		
		
		@space.entities.add text
		@text_input.add text, 0
		
		
		return text
	end
	
	# called each tick
	def update(point)
		
		return @space,@text_input
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
			
			# spawn new Text entity
			# add to space
			# attach new Text to input
				# (will display caret, even though the new object is empty)
		end
		
		# set past state
		def reverse
			text = @initial
			space, text_input = @future
			
			
			space.entities.delete text
			text_input.clear
		end
	end
end


	
end
end
end
end