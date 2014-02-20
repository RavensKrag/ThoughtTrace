# physics shapes
# resize
# other actions that modify shapes
# what methods should go where

Test.new





class Foo < Entity
	def initialize
		super()
		
						body = CP::Body.new
						shape = CP::Shape.new body 
		add_component TextSpace::Components::Physics.new body, shape
		
		add_action TextSpace::Actions::Move.new
	end
end

x = Foo.new

x[:physics] # access component by name








# How to set the physics components using builder pattern?
# ie) not in the #initialize method?


# this is for resolving the dependencies of Actions / Components,
# not attaching those things to the Entity objects

# --- procedure 
# grab dependency list from action / component
# resolve symbols into variables within Entity instance
# assign data in variables back into action / component which provided the dependency list

def foo(action_or_component, components)
	components.each do |comp|
		# can't do this right now
		# would rather not expose adding new components this freely
		action_or_component[comp.class.interface] = comp
		
		
		
		
		
		# use standard component adding interface
		# this will check dependencies though,
		# so that could get weird?
		
		# more like it will resolve symbols, and unresolved symbols
		# will result in errors
		action_or_component.add_component comp
		
		
		
		thingy.actions[:name] = dep
		thingy.components[:name] = dep
	end
end




def foo(thing, actions=[], components=[])
	actions.each do |a|
		thing.actions[a.class.interface] = a
	end
	
	components.each do |c|
		things.components[c.class.interface] = c
	end
end




thing.resolve_actions(action_list)
thing.resolve_components(component_list)
# it's not the resolving step though, it's more of an assigment step



# batch assign things, instead of having to assign one at a time
thing.assign_actions(action_list)
thing.assign_components(component_list)





actions.each {|a| thing.actions[a.name] = a }



new_action.actions = actions
new_action.components = components