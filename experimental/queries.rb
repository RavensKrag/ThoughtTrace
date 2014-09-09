
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












# query mark / unmark methods

class Foo
	def initialize(space)
		@space = space
		
		@collision_manager = ThoughtTrace::Queries::CollisionManager.new @space
		
		
		# The same style object should be used for all Queries
		@style = ThoughtTrace::Style::StyleObject.new
		@style.tap do |s|
			s[:color] = Gosu::Color.argb(0xaa7A797A)
		end
	end
	
	
	
	
	def mark_query(entity)
		# the type of query object to be used will very, depending on what you want to do
		# you could ever re-bind the Query object inside the component at runtime if you like
		query = ThoughtTrace::Queries::Query.new
			# queries require access to the space,
			# but this will provided as an argument to the Query callbacks, rather than on init
		
		
		# the component will always have the same structure
		component = ThoughtTrace::Components::Query.new(@style, query)
		entity.add_component component
	end


	def unmark_query(entity)
		entity.delete_component :query
	end
end