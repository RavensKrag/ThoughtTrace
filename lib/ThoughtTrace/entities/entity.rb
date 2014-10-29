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
					
					return ThoughtTrace::Actions::NullAction
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