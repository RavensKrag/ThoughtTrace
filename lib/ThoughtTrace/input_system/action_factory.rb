module InputSystem
	

# Create new actions based on name,
# sending the appropriate arguments to Action initialization as necessary.
class ActionFactory
	def initialize(mapping={})
		@conversion_table = mapping # property name => value
		
		data = "
			+ThoughtTrace::Entity
			+	ThoughtTrace::Queries::Query
		"
		data.lstrip!
		
		@hierarchy = parse_text_tree(data)
		# p @hierarchy
	end
	
	
	
	def create(obj, action_name)
		# convert argument symbols into real variables
		conversions = {
			# entity conversion must be specified here, because it is dynamic
			# (as opposed to in the initializer, which would be static)
			:entity => obj
		}.merge @conversion_table
		
		
		
		
		
		
		type = get_type(obj)
		action_class = get_action(type, action_name)
		
		
		
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
	
	# parse a text-based format for a tree,
	# and return a hash {child => parent}
	def parse_text_tree(data)
		# parse text
		pairs = 
			data.each_line.collect do |line|
				line.chomp!                      # strip trailing newline
				line.rstrip!                     # strip trailing whitespace (redundant?)
				line.lstrip!                     # strip leading whitespace (redundant?)
				line[0] = ''                     # remove the first character of each line
				next if line == ''               # skip blank lines
				
				x = line.split(/\t/)
				# p line
				# p x
				# count indentation level
				indents = 0
					x.each do |i|
						break if i != ''
						indents += 1
					end
				
				# extract the actually relevant string (ie, not the whitespace stuff)
				name = x.last
				
				# convert the name into an actual constant
				name = Kernel.const_get name
				
				[indents, name]
			end
		pairs.compact!
		# p pairs
		
		# use extracted data to form proper data structure
		hierarchy = Hash.new
		
		pairs.each_with_index do |pair, index|
			next if index == 0
			child_indent, child = pair
			
			# set the parent to nil.
			# this is the default, and will generally be overridden
			hierarchy[child] = nil
			
			# attempt to find a proper parent
			pairs[0..index].reverse_each do |parent_indent, parent|
				if parent_indent < child_indent
					# the parent has been found
					hierarchy[child] = parent  # set the parent, 
					break                      # and short-circuit
				end
			end
		end
		
		
		return hierarchy
	end
	
	
	
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
	def get_action(klass, name)
		# expects names as standard symbols, rather than in constant-symbol format
		# ex) expected    -  :move_over_there
		#     rather than -  :MoveOverThere
		
		# NOTE: I think this is a cleaner interface, but it requires a bunch of string manipulation. As this is something that needs to be called very often, it may become a major source of latency.
		# The weird part is really that you're using symbols in a not-very-symbol-like way
		# so the solution may actually be just to use Strings instead
		# as constant lookup can also be done using strings
		
		
		# p [klass.to_s, name]
		name_const = name.to_s.constantize
		
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
				return ThoughtTrace::Actions::NullAction
			else
				# trigger recursion to find the Action in question 
				parent = @hierarchy[klass]   # try taking specially defined exceptions
				parent ||= klass.superclass  # but if there aren't any, just go the standard way
				
				return get_action(parent, name)
			end
		end
	end
end



end