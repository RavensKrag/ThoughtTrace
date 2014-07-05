module ThoughtTrace
	module Actions


class BaseAction
	# NOTE: You might think that setting @entity in #press would remove the need to allocate a new ClickAndDragController object all the time. But that just means that the controller would have to be more aware of how Action works, which is not desirable.
	
	def initialize(space, selection, text_input, clone_factory, target)
		@space = space           # for queries and modifications to the space (ex, new objects)
		@selection = selection   # for altering the selection, or just querying it
		@text_input = text_input # for manipulating the text input buffer
		@clone_factory = clone_factory
		
		@target = target         # That which the Action is perform on
	end
	
	# outer API
	# used to give external code something to call
		# called on first tick
		def press(point)
			@initial_state = setup(point)
		end
		
		# called each tick
		def hold(point)
			# IMPLEMENTATION core
			modified_state = update(point)
			
			# MEMO creation (pseudo return)
			memo_class = self.class.const_get 'Memento'
			@memo = memo_class.new(@target, @initial_state, modified_state)
			@memo.forward
		end
		
		# called on final tick
		def release(point)
			cleanup(point)
			
			#NOTE: If #press runs, and then #release (no #hold) @memo will be nil. May want to do something about that, because having to check for returns that are nil might get annoying.
			return @memo
		end
		
		def cancel
			# the memo is always created during the #hold phase
			# so, if there is no @memo, no #hold has been executed yet
			# this means that no change has yet been made to the @entity
			# thus, nothing needs to be reversed
			# (more importantly, nothing can be reverted without the @memo)
			@memo.reverse if @memo
		end
	
	
	
	
	# inner API
	# separate from outer API so that you don't have to think about
	# creating or managing memos in child class implementation
		# called on first tick
		# returns value(s) passed to Memento as @initial
		def setup(point)
			
		end
		
		# called each tick
		# returns value(s) passed to Memento as @future
		def update(point)
			
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
	class Memento
		# TODO: insure that #forward and #reverse maintain the redo / undo paradigm. Currently, you could run #forward twice in a row, to apply the operation twice. That's not desirable.
		def initialize(entity, initial_state, future_state)
			@entity = entity
			
			@initial = initial_state # encapsulates the condition before execution
			@future = future_state   # encapsulates condition after execution
		end
		
		# set future state
		def forward
			
		end
		
		# set past state
		def reverse
			
		end
	end
end



end
end