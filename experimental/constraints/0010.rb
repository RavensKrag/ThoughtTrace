


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