module InputSystem
	

# Create new actions based on name,
# sending the appropriate arguments to Action initialization as necessary.
class ActionFactory
	def initialize(mapping={})
		@conversion_table = mapping # property name => value
	end
	
	
	
	def create(obj, action_name)
		# obj = extract(point)
		type = categorize(obj)
		
		action = get_action(type, action_name, obj)
	end
	
	
	
	
	private
	
	# # extract
	# def extract(point)
	# 	# point = @mouse.position_in_space
	# 	list = @space.point_query(point)
		
	# 	obj = list.some.set.of.operations
	# end

	# categorize
	def categorize(obj)
		if obj.nil?
			# space is empty at desired point
			
			# no target, because most actions in empty space create new things
			# the target supposed to be a thing which already exists
			# but that doesn't make sense for an action that creates something new
			
			ThoughtTrace::Actions::EmptySpace
		elsif obj[:query]
			# ThoughtTrace::Queries::Query
			
			# use specific Query type for action polymorphism
			obj[:query].class
		else
			# could be a Group or an Entity
			# how do you handle prefabs? are those different in some way?
			# I think they're just groups?
			obj.class
		end
	end
	
		
	
	# maybe these steps overlap?
	# like, maybe there's something that you need to do in extract that depends on type?
	# then you could create one method that returns the obj and it's "type"
	# but idk, that seems like it would be odd
	
	
	
	
	
	
	
	def get_action(klass, name, target)
		# convert argument symbols into real variables
		conversions = {
			:entity => target     # entity conversion must be specified here, because it is dynamic
		}.merge @conversion_table
			
			
		action_class = klass.action_get(name)
		
		args = action_class.argument_type_list.collect{|type| conversions[type] }
		action = action_class.new(*args)
		
		
		# warn about undefined actions
		# not something you want to throw an exception for
		# (some buttons just don't have things bound to them, and that's ok)
		warn "#{klass.inspect} does not define action '#{name}'" if action.null_action?
		
		
		
		return action
	end
	
	
	
end



end