class Entity
	def initialize
		@components = Hash.new
		
		@actions = Hash.new
	end
	
	
	
	def add_action(action_class)
		# require components to be added first.
		# Trying to add actions before required components results in an exception being thrown.
		
		
		
		# Resolve dependency names into actual variables,
		# and then pass them to the Action constructor
		
		
		
		# Having the exception here implies that this is the only way to create Actions
		# This is the intent of this system, but does it limit expansion?
		components = action_class.components.inject(Hash.new) do |group, component_name|
			component = @components[component_name]
			
			if component.nil?
				raise "Component #{component_name} required by #{action_class} in #{self}"
			end
			
			group[component_name] = component
			group
		end
		
		actions = action_class.actions.inject(Hash.new) do |group, action_name|
			sub_action = @actions[action_name]
			
			if sub_action.nil?
				raise "Action #{action_name} required by #{action_class} in #{self}"
			end
			
			group[action_name] = sub_action
			group
		end
		
		
		# TODO: Change the way you get names out of an action class. This will return the string form of the class's name, which is not the "name" of the action, necessarily.
		@actions[action_class.name] = action_class.new(components, actions)
		
		return nil # prevent leaking of the @actions collection
		# consider returning this Entity instead?
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		components = action.components.collect do |component_name|
			component = @components[component_name]
			
			if component.nil?
				raise "Component #{component_name} required by #{action} in #{self.class}"
			end
			
			component
		end
		
		actions = action.actions.collect do |action_name|
			sub_action = @actions[action_name]
			
			if sub_action.nil?
				raise "Action #{component_name} required by #{action} in #{self.class}"
			end
			
			sub_action
		end
		
		
		
		@actions[action.name] = self.new(
				action.name, 
				Hash[action.components.zip components],
				Hash[action.actions.zip actions]
		)
		
		return nil # prevent leaking of the @actions collection
		# consider returning this Entity instead?
		
		
		
		
		
		
		
		
		
		
		
		components = action.components.inject(Hash.new) do |group, component_name|
			component = @components[component_name]
			
			if component.nil?
				raise "Component #{component_name} required by #{action} in #{self.class}"
			end
			
			group[component_name] = component
			group
		end
		
		actions = action.actions.inject(Hash.new) do |group, action_name|
			action = @actions[action_name]
			
			if action.nil?
				raise "Action #{component_name} required by #{action} in #{self.class}"
			end
			
			group[action_name] = action
			group
		end
		
		
		
		@actions << self.new(action.name, components, actions)
		
		return nil # prevent leaking of the @actions collection
		# consider returning this Entity instead?
	end
	
	def add_component(component)
		# require dependencies to be added first
		# If an component is added before any of the components it depends on, throw exception.
		
		
		
		components = action.components.collect do |component_name|
			component = @components[component_name]
			
			if component.nil?
				raise "Component #{component_name} required by #{action} in #{self.class}"
			end
			
			component
		end
		
		
		
		@actions << self.new(
				action.name, 
				Hash[action.components.zip components],
				Hash[action.actions.zip actions]
		)
		
		return nil # prevent leaking of the @actions collection
		# consider returning this Entity instead?
		
		
		
		
		
		
		
		
		
		
		components = action.components.inject(Hash.new) do |group, component_name|
			component = 
			
			if component.nil?
				raise "Component #{component_name} required by #{action} in #{self.class}"
			end
			
			group[component_name] = component
			group
		end
		
		@actions << self.new(action.name, components)
		
		return nil # prevent leaking of the @actions collection
		# consider returning this Entity instead?
	end
end