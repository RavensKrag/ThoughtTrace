=begin

need to be able to easily plop down queries
	just an human interface problem?


are queries a type of entity?
	they have physics component, but they don't have the actions of an Entity

with no actions, should the Physics component should be used?
something with the same interface?
a rejuggling of the basic Chipmunk facilities?


but queries need to be resized and moved the same way Entities are
or at least the actions need to feel the same
so maybe they're the same thing?

	consider how the queries are resized
	consider if the Entity actions can provide proper callbacks for resizing
	if it is necessary for Queries to be notified of such a thing
		
		TEST THIS OUT
		what happens to collisions if a shape is resized?
		will the resulting overlap / removal of overlap be evaluated correctly?
		it should be - just happens on the next physics space tick


build on physics collisions with sensor objects more than Chipmunk queries

=end


		
# should be allowed to have queries of different shapes though...

# TODO: Update geometry when style is updated, and vice versa. (or else maybe width and height shouldn't be stored in Style)




# should be using groups or layers potentially to do broad culling




	
# but now you have to add a component externally
# I mean...
# this is permissible with the current API,
# but idk if it's wise?
# but it's not like you can ever delete components, so I suppose that's ok?
entity.add_component Query.new entity

# but I think you may need to remove the Query attribute on things occasionally
# it's not really an innate property
# but something that an Entity might have
# or might not have
