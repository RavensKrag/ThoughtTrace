


visualization = Visualization.new

# don't need to serialize the cache,
# so it's nice to have it as a separate object :D
cache = Hash.new

monad = Monad.new(@entities)

constraint = Constraint.new


monad.all_pairs do |a,b|
	data = constraint.foo(a,b)
	key = [a,b]
	
	
	if cache[key]
		# call the constraint if the value has changed
		if cache[key] != data
			constraint.call(a,b) 
			cache[key] = data
			
			
			visualization.activate
		end
	else
		# no data stored yet
		cache[key] = data
		next
	end
end














class Collection
	# currently assuming constraints are method objects
	# yes. method. objects.
	# take the containing object and call #method(name) to retrieve the method object
	def add(constraint, monad_type, visualization_type, *entity_list)
		monad         = monad_type.new(constraint_type, entity_list)
		visualization = visualization_type.new(entity_list)
		
		cache = Hash.new
		
		
		@list << [cache, constraint, monad, visualization]
	end
	
	def update
		@list.each do |cache, constraint, monad, visualization|
			monad.all_pairs do |a,b|
				data = constraint.foo(a,b)
				key = [a,b]
				
				
				if cache[key]
					# call the constraint if the value has changed
					if cache[key] != data
						constraint.call(a,b) 
						cache[key] = data
						
						
						visualization.activate
					end
				else
					# no data stored yet
					cache[key] = data
					next
				end
			end

			
			
			
			
			visualization.update
		end
	end
	
	def draw
		@list.each do |cache, constraint, monad, visualization|
			monad.all_pairs { |a,b| visualization.draw(a,b)  }
			
			# monad.send(visualization.relationship) do |*args|
			# 	visualization.draw(*args)
			# end
		end
	end
end


collection.add Constraints::LimitHeight.new(->(h){ 0.20*h }), All, Underline,  e1, e2, e3, e4, e5
