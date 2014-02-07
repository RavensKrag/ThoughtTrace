class Entity
	def initialize
		@components = Hash.new
		@actions = Hash.new
	end
	
	def update
		
	end
	
	def draw
		
	end
	
	
	
	def add_action(action_class)
		# require components to be added first.
		# Trying to add actions before required components results in an exception being thrown.
		
		
		
		# Resolve dependency names into actual variables,
		# and then pass them to the Action constructor
		
		
		
		# Having the exception here implies that this is the only way to create Actions
		# This is the intent of this system, but does it limit expansion?
		components = action_class.dependencies[:components].inject({}) do |group, component_name|
			component = @components[component_name]
			
			if component.nil?
				raise "Component #{component_name} required by #{action_class} in #{self}"
			end
			
			group[component_name] = component
			group
		end
		
		actions = action_class.dependencies[:actions].inject({}) do |group, action_name|
			sub_action = @actions[action_name]
			
			if sub_action.nil?
				raise "Action #{action_name} required by #{action_class} in #{self}"
			end
			
			group[action_name] = sub_action
			group
		end
		
		
		
		
		
		
		
		
		
		
		
		# # select all components that could not be resolved into real variables
		# unresolved_dependencies = {}.select{ |k,v| v == nil }
		# unless unresolved_dependencies.empty?
		# 	raise "Components #{unresolved_dependencies.join(', ')} are required by #{action_class} in #{self}"
		# 	raise "#{action_class} in #{self} needs missing components: #{unresolved_dependencies.join(', ')}"
		# end
		
		
		
		
		
		
		
		
		
		
		if @actions.has_key? action_class.interface
			# # Dependencies should be good to go, but need to replace the old action
			# # (is it safe to say the dependencies are the same?)
			
			# # Iterate over all actions which list the desired action as a dependency
			# @actions.select{ |name, action| action.class.actions.include? action }
			# .each do |action|
			# 	action.actions[action_class.name] = 
			# end
			
			
			
			
			
			# @actions.select{ |name, action| 
			# 	action.class.dependencies[:actions].include? action_class.name 
			# }.each do |name, action|
			# 	action.actions[action_class.name] = 
			# end
		end
		
		
		
		
		# TODO: Change the way you get names out of an action class. This will return the string form of the class's name, which is not the "name" of the action, necessarily.
		
		# NOTE: This method of passing components and actions means that if a different action is bound to the Entity at a later time, the change will not be reflected.  Consider just passing directly the @components and @actions variables.
		# (But that has it's own problems, as you don't want people outside of the Entity to be able to add/remove from those collections.  You just want them to have the latest updates.)
		@actions[action_class.interface] = action_class.new(components, actions)
		
		
		interface = action_class.interface
		meta_def interface do
			return @actions[interface]
		end
		
		
		
		return nil # prevent leaking of the @actions collection
		# consider returning this Entity instead?
	end
	
	def add_component(component_class)
		# require dependencies to be added first
		# If an component is added before any of the components it depends on, throw exception.
		
		
		components = component_class.dependencies[:components].inject({}) do |group, component_name|
			component = @components[component_name]
			
			if component.nil?
				raise "Component #{component_name} required by #{action_class} in #{self}"
			end
			
			group[component_name] = component
			group
		end
		
		
		@components[component_class.interface] = component_class.new(components)
		
		return nil # prevent leaking of the @actions collection
		# consider returning this Entity instead?
	end
end