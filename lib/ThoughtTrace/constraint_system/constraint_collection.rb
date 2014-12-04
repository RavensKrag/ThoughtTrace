module ThoughtTrace
	module Constraints



class Collection
	# currently assuming constraints are method objects
	# yes. method. objects.
	# take the containing object and call #method(name) to retrieve the method object
	def add(constraint, enumerator_type, visualization_type, *entity_list)
		all_pairs     = enumerator_type.new(entity_list)
		visualization = visualization_type.new(entity_list)
		
		cache = Hash.new
		
		
		@list << [cache, constraint, all_pairs, visualization]
	end
	
	def update
		@list.each do |cache, constraint, all_pairs, visualization|
			all_pairs.each do |a,b|
				data = constraint.foo(a,b)
				pair = [a,b]
				
				
				
				if baz?(cache, pair, data)
					constraint.call(a,b)
					cache[pair] = data
					
					
					visualization.activate
				end
			end
			
			# NOTE: the 'All' monad should be optimized
			# so that it can execute in 2n, rather than n(n-1) time.
			# but this kinda means that the cache needs to be part of the monad?
			# because for the All monad, only piece of data needs to be cached,
			# because the all Entities in the relation should have the same value
			
			
			# This attempted restructuring
			# so that the All monad can be optimized to 2n doesn't actually work
			# because it assumes that constraints are always propagating constraints
			# if it's a limiting constraint, you must test pairwise, you can't optimize to testing only one
			
			
			# ie
			# it will only work when you have a constraint that
			# depends only on change in A (the source) rather than also depending on changes in B (the sink)

			
			
			
			
			visualization.update
		end
	end
	
	def draw
		@list.each do |cache, constraint, all_pairs, visualization|
			all_pairs.each { |a,b| visualization.draw(a,b)  }
			
			# monad.send(visualization.relationship) do |*args|
			# 	visualization.draw(*args)
			# end
		end
	end
	
	
	private
	
	# check the cache
	# return true if the constraint needs to be run again
	def baz?(cache, pair, data)
		# there is stored data but it's old, or no data has yet been stored
		cache[pair] && cache[pair] != data or cache[pair].nil?
	end
end


end
end