module ThoughtTrace
	class Text
		module Actions


class Edit < Entity::Actions::Action
	# called on first tick
	def setup(point)
		
	end
	
	# return two values: past and future used by Memento
	# called each tick
	def update(point)
		
		
		# past and future aren't really used
		# but need to smuggle the text input handle into the Memento somehow
		return @text_input,point
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
			text_input = @past
			point = @future
			
			
			text_input.add @entity, @entity.nearest_character_boundary(point)
		end
		
		# set past state
		def reverse
			text_input = @past
			point = @future
			
			text_input.clear
		end
	end
end



end
end
end