module ThoughtTrace
	module Actions
		module EmptySpace


class SpawnText < Actions::BaseAction
	# called on first tick
	def setup(point)
		@origin = point
		
		return @origin
	end
	
	# return two values: past and future used by Memento
	# called each tick
	def update(point)
		
		return @space, @text_input
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
	# (Consider better name. Current class name derives from a design pattern.)
	# (this class also has ideas from the command pattern, though)
	# TODO: consider that writing new versions of Memento may be unnecessary if the Memento always passes the @future / @past value(s) to #forward / #reverse. That's not currently what's happening necessarily, but that might be a good direction to go in.
	ParentMemento = self.superclass.const_get 'Memento'
	class Memento < ParentMemento
		# set future state
		def forward
			# TODO: new Text should have the same size, font, etc as the last Text object accessed. ie, user should be able to create multiple similar Text objects in succession, without having to rely on the default font
			
			point = @past
			space, text_input = @future
			
			
			@text = ThoughtTrace::Text.new font
			@text[:physics].body.p = point
			
			
			space.entities.add @text
			text_input.add @text
			
			
			
			# spawn new Text entity
			# add to space
			# attach new Text to input
				# (will display caret, even though the new object is empty)
		end
		
		# set past state
		def reverse
			point = @past
			action = @future
			
			
			text = @text
			
			action.instance_eval do
				@space.entities.delete text
				@text_input.clear
			end
		end
	end
end


	
end
end
end