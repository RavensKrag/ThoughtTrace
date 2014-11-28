

collection.add(update_fx, draw_fx, trigger_fx, break_fx => break_callback)



collection.add collision_obj



collection = Collection.new
collection.add Constraint.new @entities[0], @entities[1]
collection.add Constraint.new @entities[2], @entities[5]
collection.add Constraint.new @entities[4], @entities[9]
collection.add Constraint.new @entities[2], @entities[3]


# separate objects for rendering where possible,
# to maximize reuse
# (ie, Gunpoint-style flowing cyber line could be one class, in the same way the text caret is a class)




# essentially, what you want is currying:
constraint(e1,e2, update_fx, draw_fx, trigger_fx, break_fx => break_callback)






module Constraints



# core class.
# instances of this (or descendants)
# will be stored in a collection, and managed as the "true constraints"
class Foo
	def initialize(trigger, apply_tick, visualize)
		# where is the monad?
		@trigger = trigger
		@apply_tick = apply_tick
		@visualize = visualize
	end
	
	
	
	
	# only allow running this once per game tick
	def update
		@monad.each_pair do |a,b|
			if @trigger.call
				@apply_tick.call(a, b)
			end
		end
		
		@visualize.update
	end
	
	
	# always render constraint, even if it has not been updated
	# (but maybe it should have a different appearance when it has been updated recently?)
		# can add that later. would actually be complicated
		# would have to track ticks,
		# like the way the text input caret works
		# in order to make sure that it doesn't just render the info for one frame and then go away
		# because no one would be able to see that
	def draw
		@visualize.draw
	end
end




# visualization class
class Baz
	def initialize
		
	end
	
	def update
		
	end
	
	def draw
		
	end
end




class Monad
	def initialize
		
	end
	
	
	def and_then(&block)
		
	end
end



# 1-way
class Directed < Monad
	def and_then(&block)
		
	end
end

# 2-way
class Mutal < Monad
	def and_then(&block)
		
	end
end

# n-way 
class All < Monad
	def and_then(&block)
		
	end
end




end


constraint = Directed.new Constraint.new(e1,e2)
@collection.add constraint





@collection.add SyncHeight, Directed, e1, e2
@collection.add SyncHeight, Mutual,   e1, e2
@collection.add SyncHeight, All,      e1, e2, e3, e4, e5








# each pair should only return pairs that need to be updated
each_pair do |a,b|
	@apply_tick.call(a, b)
end


class Foo
	def initialize
		
	end
	
	def each_pair(&block)
		
		block.call(a,b)
	end
end


# if the data in A has changed, then fire the constraint
# the constraint will determine how the data is translated
# from object A to object B





# what determines how the constraint is visualized?
# the type of constraint?
# the pairing type? (1-way, 2-way, n-way?)
# is it some combination of both?
# are there some other factors?







#                           (monad?)
#            constraint,  pairing type,  visualization,  entity list
@collection.add SyncHeight, Directed, FlowLine,       e1, e2
@collection.add SyncHeight, Mutual,   FlowLine,       e1, e2
@collection.add SyncHeight, All,      FlowLine,       e1, e2, e3, e4, e5

@collection.add SyncHeight, Directed, Arrow,          e1, e2
@collection.add SyncHeight, Mutual,   Arrow,          e1, e2
@collection.add SyncHeight, All,      Arrow,          e1, e2, e3, e4, e5


@collection.add SyncHeight, Directed, SingleArrow,    e1, e2
@collection.add SyncHeight, Mutual,   DoubleHeaded,   e1, e2
@collection.add SyncHeight, All,      Underline,      e1, e2, e3, e4, e5


# colors from constraint type, exact style from visualization

# (could also define a "Sequential" type to transfer data from A -> B -> C -> D)
# (not sure how useful that would be in the context of this system though)


base = @entities[0]

@collection.add LimitHeight.curry(base), Individual, Underline,      [e1]
@collection.add LimitHeight,             Each,       Underline,      [e1, e2, e3, e4, e5]
@collection.add LimitHeight,             Dependent,  SingleArrow,    [e1, e2]


@collection.add SyncHeight,              Directed,   SingleArrow,    [e1, e2]
@collection.add SyncHeight,              Mutual,     DoubleHeaded,   [e1, e2]
@collection.add SyncHeight,              All,        Underline,      [e1, e2, e3, e4, e5]

# NOTE: the Constraint.curry needs to return an object, which when initialized using .new, creates an instance of the curryed constraint type. it's a similar structure to how metaclasses are wrappers on classes. you need to return a wrapper object which will finish up the initialization.



# Individual     1   single item. applies constraint based on a parameter, rather than another obj
# Each           1   each and every item in the list
# Dependent     1-2  similar to Individual, but derives parameter from the properties of some obj
# Directed       2   1-way relationship between two objects
# Mutual         2   2-way relationship between two objects
# All            2   n-way relationship between n objects  (n! connections)


# Dependent is essentially a wrapper type, that bridges the logic of Individual and Directed
# it uses the actual constraint tick application from an Individual constraint,
# but applies it between two entities, like a Directed constraint


# Perhaps this should be inverted:
# unary constraints are just binary constraints,
# but with some parameters replaced with hard values, instead of being derived from another object

# this is true for the LimitHeight constraint I have envisioned here,
# but that sorta implies that it is not a "true" unary constraint
# as it has a binary form as well

# consider Ruby's splat operator, which is inherently unary
# as opposed to negation, which could (at least mathematically) be rephrased as a binary operation






# unary
# binary
# pseudo-unary  (binary with default arguments)
# n-ary         (can be defined as binary)



# defined as binary
# defined as unary

# used as unary
# used as binary

# anything defined as binary can be used as binary, or n-ary
# some things defined as binary can have sensible defaults for unary usage
# some things defined as binary can be "curried" to supply one the arguments -> unary
# inherently unary operations can only ever be unary




unary[@entities[0]]


binary[@entities[0], @entities[1]]


pseudo_unary = binary.curry[value]
pseudo_unary[@entities[0]]
# but you can't do a straight curry,
# because the binary fx expects an Entity for both arguments,
# rather than a value, and an entity
# (simplest way would be to pass a dummy object. you could wrap that up in some syntactic sugar, and call it a "curry" operation)
pseudo_unary = binary.curry(v1, v2, v3) # pass whatever values that would be extracted from Entity
pseudo_unary[@entities[0]] # pass in another Entity to complete the operation
# this has problems with argument order
# you could use named arguments, but what would you even name them,
# and how would you perform the substitution?
# 
# in the context of the full completed system,
# in which you can easily make and manipulate Entities and Constraints,
# it may just be better to shove a full Entity in, and curry that




n_ary = join(binary, [@entities[0], @entities[1], @entities[2], @entities[3]])
n_ary[]
# or, maybe like this?
n_ary = foo(binary)
n_ary[@entities[0], @entities[1], @entities[2], @entities[3]]



class Visualization
	def initialize(constraint)
		@constraint = constraint
	end
	
	# compute changes
	# useful for flashing, or flowing, or other animation effects
	# (may want to figure out how to turn #draw into a parametric instead?)
	def update
		
	end
	
	# actually render the thing
	def draw
		
	end
end

class SingleArrow < Visualization
	def update
		
	end
	
	def draw
		# need to draw iteration block from the collection of entity objects
		# @constraint and @monad are probably not the objects to hold these lists
		@constraint.each_pair do |a,b|
			draw_line(a[:physics].center, b[:physics].center, color:@constraint.style[:color])
		end
	end
end

class Underline < Visualization
	def update
		
	end
	
	def draw
		@constraint.each do |x|
			draw_underline(x, color:@constraint.style[:color])
		end
	end
end

# some visualizations are draw on each pair,
# some are draw on each object individually
# (need to be careful about stacking multiple underlines, though)