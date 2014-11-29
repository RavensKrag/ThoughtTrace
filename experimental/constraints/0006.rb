module Constraints



# constraint functions go here
# all functions take two arguments
# each argument is an entity
# the data shall flow from entity A to entity B
class << self
	def foo(a,b)
		
	end
end








# pass pairs of objects to the block
# only pass the pairs if the objects require a tick of the constraint applied to them
# the specific logic will have to change for each monad type
# (not even sure if these are actually monads or not)
class Monad
	def initialize(entity_list)
		@entities = entity_list
	end
	
	# use this name instead of "each_pair" because it's not 'each and every pair'
	# only reveals the relevant pairs
	def all_pairs(&block)
		# this one is a dummy implementation
		# it doesn't work
		block.call(a,b)
	end
	
	def necessary_pairs(&block)
		# this implementation does work, assuming that #all_pairs is implemented correctly
		all_pairs do |a,b|
			block.call(a,b) if update_condition(a)
		end
	end
	
	def each(&block)
		@entities.each &block
	end
	
	def update_condition(entity)
		return true
	end
end



# NOTE: these monads need to be further refined, so that they only expose pairs that need to be updated, rather than exposing all pairs every time

# NOTE: consider using yield instead of block.call()

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







class Visualization
	# allow visualizations to specify the iterator, without tight binding to Monad
	class << self
		private
		
		def relationship(type)
			@type = type
		end
		
		public
		
		def relationship
			@type
		end
	end
	
	# a bit of syntactic sugar
	def relationship
		self.class.relationship
	end
	
	
	
	
	
	def update
		# update animation state, etc
		# do not make any changes to Entity data
		# 
		# this phase has now become completely independent of entity data
		# (maybe this should be removed?)
	end
	
	def draw
		# apply visualization data to the Entity objects as necessary
		# visualize the given pair of entities
	end
end


class SingleArrow < Visualization
	relationship :all_pairs
	
	def update
		
	end
	
	def draw(a,b)
		
	end
end

class Underline < Visualization
	relationship :each
	
	def update
		
	end
	
	def draw(entity)
		
	end
end








class Collection
	# currently assuming constraints are method objects
	# yes. method. objects.
	# take the containing object and call #method(name) to retrieve the method object
	def add(constraint_name, monad_type, visualization_type, *entity_list)
		# just use constraint objects to check arity, but then store by message name
		constraint = Constraints.method(constraint_name)
		
		unless constraint.arity == entity_list.size
			raise ArgumentError, "Constraint '#{constraint.name}' recieved the wrong number of arguments (#{entity_list.size} for #{constraint.arity})"
		end
		
		
		monad         = monad_type.new(entity_list)
		visualization = visualization_type.new(entity_list)
		
		@list << [constraint_name, monad, visualization]
	end
	
	def update
		@list.each do |constraint, monad, visualization|
			monad.necessary_pairs do |a,b|
				Constraints.send(constraint, a,b)
			end
			
			visualization.update
		end
	end
	
	def draw
		@list.each do |constraint, monad, visualization|
			# monad.all_pairs { |a,b| visualization.draw(a,b)  }
			
			monad.send(visualization.relationship) do |*args|
				visualization.draw(*args)
			end
		end
	end
end








end




collection = Constraints::Collection.new
collection.add :foo, All, SingleArrow,     e1, e2, e3, e4, e5

# NOTE: if you create a method object, and then the method is changed, the object remain bound to the old definition of the method. Thus, going to use message passing instead.