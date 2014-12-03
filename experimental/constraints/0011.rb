# 1-way
class Directed < Monad
	def all_pairs(&block)
		block.call(@entities[0], @entities[1])
	end
	
	def update_condition(entity)
		
	end
end

# 2-way
class Mutual < Monad
	def all_pairs(&block)
		[
			[@entities[0], @entities[1]],
			[@entities[1], @entities[0]]
		].each do |a,b|
			block.call(a,b)
		end
	end
	
	def update_condition(entity)
		
	end
end

# n-way
class All < Monad
	def all_pairs(&block)
		@entities.permutation(2) do |a,b|
			block.call(a,b)
		end
	end
	
	
	def update_condition(entity)
		
	end
end

# the first Entity in the list has the other Entities as children
class ParentAndChildren < Monad
	def all_pairs(&block)
		parent = @entities.first
		# discard the first element, without mutating the original list
		@entities.drop(1).each do |child|
			block.call(parent, child)
		end
	end
	
	
	def update_condition(entity)
		
	end
end







@list.each do |cache, constraint, monad, visualization|
	monad.all_pairs do |a,b|
		data = constraint.foo(a,b)
		pair = [a,b]
		
		
		
		if baz?(cache, pair, data)
			constraint.call(a,b)
			cache[pair] = data
			
			
			visualization.activate
		end
	end
	
	
	
	
	monad.map{   |a,b|
		# generate a bunch of data for the pairs, so you can see what has changed
		data = constraint.foo(a,b)
	
	}.and_then{  |a,b|
		# cache all the data that makes it to this point
		constraint.call(a,b)
		
		visualization.activate
	}
	# This attempted restructuring
	# so that the All monad can be optimized to 2n doesn't actually work
	# because it assumes that constraints are always propagating constraints
	# if it's a limiting constraint, you must test pairwise, you can't optimize to testing only one





	visualization.update
end