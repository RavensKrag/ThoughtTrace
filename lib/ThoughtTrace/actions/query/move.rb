module ThoughtTrace
	module Queries
		class Query
			module Actions

class Move < ThoughtTrace::Entity::Actions::Move
	@type_list = Entity::Actions::Move.argument_type_list
	# by creating a child class of an action, you inherit the initializer, but not the type list
	
	# private
	
	# def movement_delta(point)
	# 	return super(point) * -1
	# end
end



end
end
end
end