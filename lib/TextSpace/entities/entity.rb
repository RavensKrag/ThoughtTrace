module TextSpace


class Entity
	def initialize
		# These two Hashes map symbols for interface names to actual component/action instances
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
		# (exceptions are thrown when symbols attempt to resolve)
		components = resolve_components(action_class, action_class.dependencies[:components])
		actions = resolve_actions(action_class, action_class.dependencies[:actions])
		
		
		# NOTE: This method of passing components and actions means that if a different action is bound to the Entity at a later time, the change will not be reflected.  Consider just passing directly the @components and @actions variables.
		# (But that has it's own problems, as you don't want people outside of the Entity to be able to add/remove from those collections.  You just want them to have the latest updates.)
		# (Maintaining another collection is also weird though, because there's a false signifier that changes made to the cache will percolate back to the main actions collection.)
		@actions[action_class.interface] = action_class.new(components, actions)
		
		
		
		
		
		# if @actions.has_key? action_class.interface
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
		# end
		
		
		
		
		
		
		
		# Create methods for actions (similar to attr_reader)
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
		# (exceptions are thrown when symbols attempt to resolve)
		components = resolve_components(component_class, component_class.dependencies[:components])
		
		
		@components[component_class.interface] = component_class.new(components)
		
		return nil # prevent leaking of the @actions collection
		# consider returning this Entity instead?
	end
	
	
	private
	
	
	# ----- Resolve lists of symbols into actual variables -----
	
	
	# Having the exception here implies that this is the only way to create Actions/Components
	# This is the intent of this system, but does it limit expansion?
	
	
	# Gather a hash in the form {:component_name => component_instance}
	def resolve_components(commander, list_of_requirements)
		list_of_requirements.inject(Hash.new) do |group, component_name|
			component = @components[component_name]
			
			if component.nil?
				raise "Component #{component_name} required by #{commander} in #{self}"
				# raise "#{self} does not contain the component #{component_name}"
			end
			
			group[component_name] = component
			group
		end
	end
	
	# Gather a hash in the form {:action_name => action_instance}
	def resolve_actions(commander, list_of_requirements)
		list_of_requirements.inject(Hash.new) do |group, action_name|
			sub_action = @actions[action_name]
			
			if sub_action.nil?
				raise "Action #{action_name} required by #{commander} in #{self}"
				# raise "#{self} does not contain the component #{action_name}"
			end
			
			group[action_name] = sub_action
			group
		end
	end
	
	
	# # select all components that could not be resolved into real variables
	# unresolved_dependencies = {}.select{ |k,v| v == nil }
	# unless unresolved_dependencies.empty?
	# 	raise "Components #{unresolved_dependencies.join(', ')} are required by #{action_class} in #{self}"
	# 	raise "#{action_class} in #{self} needs missing components: #{unresolved_dependencies.join(', ')}"
	# end
end



end