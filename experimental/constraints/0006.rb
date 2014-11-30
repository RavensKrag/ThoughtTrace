module Constraints



# constraint functions go here
# all functions take two arguments
# each argument is an entity
# the data shall flow from entity A to entity B


# constraints are classes, rather than just functions,
# so that they can be parameterized
class Constraint
	def initialize
		
	end
	
	
	# method that actually does the work
	def call(a,b)
		
	end
end


# updates when A has changed
class PropagatingConstraint < Constraint
	def initialize
		
	end
	
	
	def call(a,b)
		
	end
end


# updates when B has changed
class LimitingConstraint < Constraint
	def initialize
		
	end
	
	
	def call(a,b)
		
	end
end




# NOTE: there is the possibility of 4 groupings:
	# flow A -> B dependent on A
	# flow A -> B dependent on B
	# flow B -> A dependent on A
	# flow B -> A dependent on B
# but I'm pretty sure that you always want the data to flow from A to B
# because I'm fairly convinced that if you wanted things the other way,
# you would just specify the constraint the other way around.
# Thus, it reduces to 2 relationships








class Foo < PropagatingConstraint
	def initialize
		
	end
	
	
	def call(a,b)
		
	end
end


class LimitHeight < LimitingConstraint
	def initialize(fx)
		@fx = fx
	end
	
	
	def call(a,b)
		# calculate what the height should be limited to
		ah = a[:physics].height
		bh = b[:physics].height
		
		h =
			case @fx.arity
				when 1
					fx[ah]
				when 2
					fx[ah,bh]
			end
		
		# enforce height limit
		b[:physics].height = h if b[:physics].height > h
	end
end



















# pass pairs of objects to the block
# only pass the pairs if the objects require a tick of the constraint applied to them
# the specific logic will have to change for each monad type
# (not even sure if these are actually monads or not)
class Monad
	def initialize(constraint_type, entity_list)
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
			next unless update_condition(a)
			
			
			
					a_changed = entity_changed?(a)
					b_changed = entity_changed?(b)
			changes =
				if a_changed and b_changed
					:both_changed
				elsif a_changed
					:a_changed
				elsif b_changed
					:b_changed
				else
					:no_change
				end
			
			
			
			block.call(a,b) unless changes == :no_change
		end
	end
	
	def each(&block)
		@entities.each &block
	end
	
	def update_condition(entity)
		return true
	end
	
	
	
	private
	
	
	# return true if the Entity has been modified since the last time the Entity was examined
	# NOTE: you need to know about the Constraint to understand what a meaningful change is
	def entity_changed?(entity)
		
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
	def add(constraint, monad_type, visualization_type, *entity_list)
		monad         = monad_type.new(constraint_type, entity_list)
		visualization = visualization_type.new(entity_list)
		
		@list << [constraint, monad, visualization]
	end
	
	def update
		@list.each do |constraint, monad, visualization|
			monad.necessary_pairs do |a,b|
				constraint.call(a,b)
			end
			
			
			monad.apply_to_necessary_pairs constraint
			
			
			
			pairs = monad.all_pairs.select &constraint.filter
			pairs.each{ |a,b| constraint.call(a,b)  }
			
			
			
			
			
			
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
collection.add Constraints::Foo.new, Directed, SingleArrow, e1, e2
collection.add Constraints::Foo.new, All,      SingleArrow, e1, e2, e3, e4, e5




# Constraints need to be able to take parameters, or you will get a lot of code duplication for no good reason
# should probably use classes over curryed procs, so you can't curry the Entity parameters
# that would get really weird.
# those last two spots need to be guaranteed to be open, 
# so that the function call inside the system will work as intended

collection.add Constraints::LimitHeight.new(->(h){ 0.20*h }), All, Underline,  e1, e2, e3, e4, e5
# insures that height never exceeds 20% of the reference object's height
# because the constraint is applied to an 'All' relationship,
# it will keep all objects in the group within 20% of each other








# NOTE: if you create a method object, and then the method is changed, the object remain bound to the old definition of the method. Thus, going to use message passing instead.


# Wanted to use message passing to allow for easy updating, but may have to think about the dynamic system later.

