module InputSystem
	

# Create new actions based on name,
# sending the appropriate arguments to Action initialization as necessary.
class ActionFactory
	def initialize(active_selection, mapping={})
		@selection = active_selection
		
		@conversion_table = mapping # property name => value
		@conversion_table[:action_factory] = self
	end
	
	
	
	def create(obj, action_name)
		# convert argument symbols into real variables
		conversions = {
			# entity conversion must be specified here, because it is dynamic
			# (as opposed to in the initializer, which would be static)
			:entity => obj
		}.merge @conversion_table
		
		
		
		
		
		
		type = get_type(obj)
		action_class = get_action(obj, type, action_name)
		
		
		
		# NOTE: remember that the action class holds both the argument list, and the obj allocator
		args   = action_class.argument_type_list.collect{|type| conversions[type] }
		action = action_class.new(*args)
		
		
		# warn about undefined actions
		# not something you want to throw an exception for
		# (some buttons just don't have things bound to them, and that's ok)
		warn "#{type.inspect} does not define action '#{action_name}'" if action.null_action?
		
		
		return action
	end
	
	
	
	
	private
	
	
	def get_type(obj)
		if obj.nil?
			# space is empty at desired point
			
			# no target, because most actions in empty space create new things
			# the target supposed to be a thing which already exists
			# but that doesn't make sense for an action that creates something new
			
			ThoughtTrace::Actions::EmptySpace # EmptySpace#action_get() defined in actions/index.rb
		elsif obj[:query] # if the Entity has a Query component
			# ThoughtTrace::Queries::Query
			
			# use specific Query type for action polymorphism
			obj[:query].callbacks.class
		else
			# could be a Group or an Entity
			
			# # note that selection is also a group
			# if @selection.include? obj
			# 	# in the active selection group
				
				
			# else
			# 	containing_groups = @space.groups.select{ |g|  g.include? obj  }
			# 	if containing_groups.empty?
			# 		# not in any groups.
			# 		# assuming this is just a standard Entity
			# 		obj.class
			# 	else
			# 		# part of one or more groups
					
			# 	end
			# end
			
			
			
			
			if @selection.include? obj
				return @selection.class
			else
				return obj.class
			end
			
			
			
			
			# how do you handle prefabs? are those different in some way?
			# I think they're just groups?
			obj.class
		end
	end

	
	# Recursively looks for an Action of a particular name.
	# Should not dig deeper than Entity, as Entity is what holds the Action structure.
	# 
	# name styled after things like "const_get" and "instance_variable_get"
	# 
	# ideally, the exception flow will percolate back "down" the inheritance chain
	# to the child class (the class that originally launched the call)
	# so that the error message on the backtrace can accurately report
	# what class was trying to access what action
	# 
	# obj    -- object trying to fire an Action
	# klass  -- current class under which we're looking for Action objects (changes with recursion)
	# name   -- name of the Action desired
	def get_action(obj, klass, name)
		# expects names as standard symbols, rather than in constant-symbol format
		# ex) expected    -  :move_over_there
		#     rather than -  :MoveOverThere
		
		# NOTE: I think this is a cleaner interface, but it requires a bunch of string manipulation. As this is something that needs to be called very often, it may become a major source of latency.
		# The weird part is really that you're using symbols in a not-very-symbol-like way
		# so the solution may actually be just to use Strings instead
		# as constant lookup can also be done using strings
		
		
		name_const = name.to_s.constantize
		# p [klass, name, name_const]
		
		begin
			return klass::Actions.const_get name_const
		rescue NameError => e
			# Traverse the hierarchy to find a class that can yield the desired Action.
			# Mostly, you will traverse the class inheritance hierarchy,
			# but there are some exceptions.
			
			if klass == ThoughtTrace::Entity or klass == ThoughtTrace::Actions::EmptySpace
				# you have reached the bottom of the chain,
				# the root of the the tree.
				# The recursion stops here
				
				# end of the road:
				# this is the base of the entire Action search system.
				# If no action has been found by this point, the action is not defined.
				warn "#{obj.class} does not define #{name || '<NIL>'}, nor does it's ancestors"
				return ThoughtTrace::Actions::NullAction
			else
				# trigger recursion to find the Action in question
				parent = get_parent(obj, klass)
				
				return get_action(obj, parent, name)
			end
		end
	end
	
	# helper method for get_action
	# ( obj and klass are the same as defined by get_action )
	def get_parent(obj, klass)
		# --- try taking specially defined exceptions
		parent =
			if obj[:query] and klass == ThoughtTrace::Queries::Query
				# if the base object has a Query component
				# you need to check the base object's class, as well as the core Query class
				obj.class
			elsif @selection.include? obj and klass == ThoughtTrace::Groups::Group
				# Group doesn't define an action, then just use the Entity action instead.
				obj.class
			end
		
		# --- but if there aren't any, just go the standard way 
		parent ||= klass.superclass
		# NOTE: Modules do not have a 'superclass', so if you end up calling this on a module, it will break. Currently do not have a need to do that, but it may come up in the future.
		
		return parent
	end
	
	
	public
	
	# list what Actions are available to a particular object
	def actions(obj, klass=nil)
		klass ||= obj.class
		
		raise TypeError, "#{klass} does not define an Action module. Can not find Actions." unless klass.constants.include? 'Actions'
		
		# TODO: combine overlapping code in this method with the code from #get_action
		
		
		list = klass::Actions.constants
		
		if klass == ThoughtTrace::Entity or klass == ThoughtTrace::Actions::EmptySpace
			# base case
			return list
		else
			# recursion
			# trigger recursion to find the Action in question 
			parent = get_parent(obj, klass)
			
			return list + actions(obj, parent)
		end
	end
end



end