module ThoughtTrace
	module Components
		
		
class Component
	include DependencyListing
	dependency_types :components
	
	
	attr_accessor :components
	
	def initialize
		
	end
	
	
	
	
	# TODO: either use meta_def for both of theses, or find some other way to solidify that they are within the same meta level
	
	def self.interface
		@name
	end
	
	# meta_def methods stick their instance variables on a Class
	# the same way that standard methods stick their instance variables on an Object
	private_meta_def 'interface_name' do |name|
		@name = name
	end
	
	
	
	
	
	
	# TODO: decide on general syntax for "callback function" names. Should they be named in a manner distinct from other methods for instant clarity and possible syntax highlighting? Should they just be like any other methods, because they pretty much are?
	# The methods in the Action flow are under this category as well, not just these methods here.
	
	# called by Entity when it adds this Component to itself
	def on_bind(entity)
		@components = resolve_dependencies(entity)
	end
	
	# called by Entity when this Component is removed from the Entity
	def on_unbind(entity)
		# not used by default Entity, but this is a useful callback to have
	end
	
	
	private
	
	
	# NOTE: if you provide one error for what dependencies are missing, you can list all missing dependencies at once. This would mean you only have to do one code-execute-fix iteration to solve the problem. Otherwise, you might have to code->run->code->run etc for a while before resolving all the dependencies
	
	# Gather a hash in the form {:component_name => component_instance}
	def resolve_dependencies(parent_entity)
		# require dependencies to be added first
		# If an component is added before any of the components it depends on, throw exception.
		# (exceptions are thrown when symbols attempt to resolve)
		component_names = self.class.dependencies[:components]
		
		component_objects = component_names.collect{ |name|  fetch_component(parent_entity, name) }
		
		
		
		x = component_names
		y = component_objects
		hash = x.zip(y).to_h
	end
	
	
	# perform error handling here and not in prime component retrial code, because there's no core way to provide errors when a component is missing.
	def fetch_component(parent_entity, name)
		component = parent_entity[name]
		
		if component.nil?
			raise "Component #{name} required by #{parent_entity} in #{self}"
			# raise "#{self} does not contain the component #{name}"
		end
		
		return component
	end
end



end
end