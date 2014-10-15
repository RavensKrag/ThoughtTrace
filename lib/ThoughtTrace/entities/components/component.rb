module ThoughtTrace
	module Components
		
		
class Component
	include DependencyListing
	dependency_types :components
	
	
	def initialize
		
	end
	
	
	
	
	# Copy the data from the other component, into this one
	# A deep copy is not necessary.
	# (This performs one copy operation. No guarantee these two objects will remain in sync.)
	def mirror(other)
		raise "Component #{self.class.name} does not define #mirror (needed for serialization)"
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
		resolve_dependencies(entity)
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
		
		missing_components = component_names.reject{ |name| parent_entity[name]  }
		
		unless missing_components.empty?
			missing_names = missing_components.join ", "
			raise "Could not find the following components on #{parent_entity}: [#{missing_names}]"
		end
	end
end



end
end