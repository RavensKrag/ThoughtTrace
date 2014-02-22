module TextSpace


class HumanAction
	def initialize(action_name)
		@action = action_name
	end
	
	# don't want to actually raise any errors here,
	# as it should be fairly common for things not to find valid targets,
	# and you shouldn't have to wrap things in "catch" all the time
	
	def press(entity_list, point)
		# query
			# pick
			# preen (reduce query scope to Entities which poses the desired action)
		# press entity
		
		
		
		# moving the pick step outside into the input handler
		# entity_list = query.pick
		
		# raise "No Entities found" unless entity_list.empty?
		
		
		entity =	entity_list.find do |entity|
						entity.respond_to? @action
					end
		
		raise "Could not find a vaild target" unless entity
		
		
		# Save same entity for later phases
		@entity = entity
		
		@entity.send(@action).press
	end
	
	# should retain the same entity from the first phase for the next two phases
	
	def hold(point)
		# hold entity
		
		@entity.send(@action).hold(point)
	end
	
	def release(point)
		# release entity
		
		@entity.send(@action).release(point)
	end
end



end