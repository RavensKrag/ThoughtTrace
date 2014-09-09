
# need to be able to easily plop down queries
# 	just an human interface problem?



# build on physics collisions with sensor objects more than Chipmunk queries


		
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
