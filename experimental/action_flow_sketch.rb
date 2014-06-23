# one of these
place_to_look = entity
place_to_look = SomeModule
place_to_look = SomeModule


# one of these
foo = @bindings[:existing]
foo = @bindings[:selection]
foo = @bindings[:empty]


# one of these
# thing to act on
baz = entity
baz = group
baz = whatever



# BOTH
action_name = foo[:click]
action_name = foo[:drag]



# this one
action_class = place_to_look.action(action_name)



# this one
action = action_class.new(a,b,c, baz)
		








entity = @space.point_query_best(point, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil)


binding = @bindings[:existing]
place_to_look = entity
target = entity


action = look_for_action(:with => name, :in => place_to_look).new(*standard_args, target)



klass.new(a,b,c, entity)
klass.new(a,b,c, group)
klass.new(a,b,c, whatever_you_act_on)
# see the symmetry?
		
		
		