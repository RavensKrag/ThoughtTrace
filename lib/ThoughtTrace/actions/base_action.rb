module ThoughtTrace
	module Actions


class BaseAction
	# TODO: default initializer defined in BaseAction should accept one argument, "target"
		# is this actually necessary?
		# would it be better for all actions to specify every possible argument in their type list?
	
	class << self
		def argument_type_list
			@type_list
		end
		
		
		private
		
		def initialize_with(*arg_names)
			# create the initializer to accept the variables as named,
			# and place them in instance variables with similar names
			# ex) @space = space
			define_method :initialize do |*args|
				assoc_list = arg_names.zip args
				assoc_list.each do |name, value|
					instance_variable_set "@#{name}", value
				end
			end
			
			# store list of argument names on the BaseAction class
			# as a class instance variable
			@type_list = arg_names
		end
	end
	
	
	
	
	
	# similar to Object#nil?
	# not very useful for this class, but very useful for descendant classes
	def null_action?
		return self.is_a? ThoughtTrace::Actions::NullAction
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
			@memo = memo_class.new(@entity, @initial_state, modified_state)
				# NOTE: @entity will be nil if entity was not specified in #initialize_with
			
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