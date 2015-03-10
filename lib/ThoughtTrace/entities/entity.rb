module ThoughtTrace


class Entity
	def initialize
		# These two Hashes map symbols for interface names to actual component/action instances
		@components = Hash.new
	end
	
	def update
		
	end
	
	def draw
		
	end
	
	# let Space know that you should be deleted
	# useful for removing empty strings, etc which can not be selected by the user
	# and contain no useful information
	def gc?
		
	end
	
	
	
	
	
	# TODO: consider creating custom Component container, so the syntax is more like entity.components.add() rather than entity.add_component()
	
	
	
	# Components provide namespacing for common subsystems. (ex, physics)
	def add_component(component)
		component.on_bind(self) # execute binding callback. handles dependency resolution, etc
		
		@components[component.class.interface] = component
		
		return nil # prevent leaking of the @actions collection
		# consider returning this Entity instead?
	end
	
	def delete_component(component_name)
		component = @components.delete component_name
		
		component.on_unbind(self) if component
	end
	
	
	# Access Components from outside the Entity
	def [](component_name)
		@components[component_name]
	end
end



end