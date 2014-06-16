module ThoughtTrace


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
	
	
	
	
	
	# TODO: Specify how Actions are attached to Entity objects
	# + specify API
	# + specify how Action interface names are related to the Actions themselves
		# manually specify interface name?
		# derived from class name?
	# The Action classes are stored on the Entity class (used as factories)
	# but should they be accessed only though the class, or through an instance as well?
		# allowing access through an instance may be slightly more convenient,
		# but first exposure to this API may be by using an instance of Entity
		# which may make it seem like the Actions can only be accessed through an instance,
		# rather than it being a convenience feature.
	class << self
		# name styled after things like "const_get" and "instance_variable_get"
		# Recursively looks for an action of a particular name within the inheritance tree
		# Should not dig deeper than Entity, as Entity is what holds the Action structure.
		
		# expects names as standard symbols, rather than in constant-symbol format
		# ex) expected    -  :move_over_there
		#     rather than -  :MoveOverThere
		
		# NOTE: I think this is a cleaner interface, but it requires a bunch of string manipulation. As this is something that needs to be called very often, it may become a major source of latency.
		# The weird part is really that you're using symbols in a not-very-symbol-like way
		# so the solution may actually be just to use Strings instead
		# as constant lookup can also be done using strings
		def action_get(action_symbol_name)
			action_const_name = action_symbol_name.to_s.constantize
			
			
			klass = self
			
			begin
				return klass::Actions.const_get action_const_name
			rescue NameError => e
				if klass == Entity
					# base of the chain
					# recursion base case
					
					# No acceptable action found.
					# Return a null object so that method chaining doesn't just fail
					
					return ThoughtTrace::Entity::Actions::NullAction
				else
					# continue recursive traversal
					
					klass = klass.superclass
					return klass.action_get(action_symbol_name)
				end
			end
		end
	end
	
	# ideally, the exception flow will percolate back "down" the inheritance chain
	# to the child class (the class that originally launched the call)
	# so that the error message on the backtrace can accurately report
	# what class was trying to access what action
	
	
	
	# Access actions from an instance.
	# 
	# This feels more natural, as Action objects are kinda like methods,
	# and while methods are attached to the class,
	# they are accessed through the instance.
	def action(action_name)
		self.class.action_get(action_name)
	end
	
	
	
	
	
	# Actions provide a high-level(ish) interface for manipulating the data in Components
	def add_action(action)
		# require components to be added first.
		# Trying to add actions before required components results in an exception being thrown.
		# (exceptions are thrown when symbols attempt to resolve)
		components = resolve_components(action, action.class.dependencies[:components])
		actions = resolve_actions(action, action.class.dependencies[:actions])
		
		
		# NOTE: This method of passing components and actions means that if a different action is bound to the Entity at a later time, the change will not be reflected.  Consider just passing directly the @components and @actions variables.
		# (But that has it's own problems, as you don't want people outside of the Entity to be able to add/remove from those collections.  You just want them to have the latest updates.)
		# (Maintaining another collection is also weird though, because there's a false signifier that changes made to the cache will percolate back to the main actions collection.)
		
		
		action.components = components
		action.actions = actions
		
		
		
		@actions[action.class.interface] = action
		
		
		
		
		
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
		interface = action.class.interface
		meta_def interface do
			return @actions[interface]
		end
		
		
		
		return nil # prevent leaking of the @actions collection
		# consider returning this Entity instead?
	end
	
	# Components provide low-level(ish) control over data.
	# They are generally manipulated though actions,
	# but it should be possible to access the components directly.
	# Actions allow for complex manipulations that span multiple Components.
	# Manipulation of individual components is only for when you want to get under the hood.
	# Use of Actions should generally be preferred over direct manipulation.
	def add_component(component)
		# require dependencies to be added first
		# If an component is added before any of the components it depends on, throw exception.
		# (exceptions are thrown when symbols attempt to resolve)
		components = resolve_components(component, component.class.dependencies[:components])
		
		
		component.components = components
		
		@components[component.class.interface] = component
		
		return nil # prevent leaking of the @actions collection
		# consider returning this Entity instead?
	end
	
	
	# Access Components from outside the Entity
	def [](component_name)
		@components[component_name]
	end
	
	# Return list of action names
	def action_names
		list = Array.new
		@actions.each do |name, action|
			list << name
		end
		
		return list
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