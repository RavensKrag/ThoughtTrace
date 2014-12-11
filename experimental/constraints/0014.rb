
# sketch a way to set initial values for parameters in code,
# but then allow for the graphical system to
# easily modify certain values that had been exposed

p = 
	let :a => 0.8 do |vars, h|
		# 0.8*h
		vars[:a]*h
	end

constraint = LimitHeight.new(p)

# but you want to be able to re-load this code,
# and have it update any of the constraints that it has been linked into











x     = Struct.new(:a)
scope = x.new(0.8)

scope.setup do |h|
	@a * h
end

scope[h] # use this to execute the code. Same calling interface as Proc


constraint = LimitHeight.new(scope)








list_a = Array.new
list_b = Array.new
i = 0

list_a[i] = PointerWrapper.new(list_b, i) # wrapper should behave like the 'scope' variable


	x     = Struct.new(:a)
	scope = x.new(0.8)
	
	scope.setup do |h|
		@a * h
	end


list_b[i] = scope








parameterized = Array.new
wrappers      = Array.new
active        = Array.new

i = 0




x     = Struct.new(:a)
scope = x.new(0.8)

scope.setup do |h|
	@a * h
end

parameterized[i] = scope


wrappers[i]      = PointerWrapper.new(parameterized, i)

active[i]        = [wrappers[i], DrawEdge, Directed]

i += 1
# when doing this for the first time, you need to advance the current count
# when accessing, this isn't necessary




# now you can just update the variable in one place, and it will propagate all over the place
# but you can't GC the constraint until all links are removed
# and the final link will be inside the cached wrapper in the wrappers[] collection.
# might need to remove the wrappers collection, then


















parameterized = Array.new
wrappers      = Array.new
active        = Array.new

i = 0




p = 
	let :a => 0.8 do |vars, h|
		# 0.8*h
		vars[:a]*h
	end

parameterized[i] = p



active[i]        = [[LimitHeight, PointerWrapper.new(parameterized, i)], DrawEdge, Directed]

i += 1

# even if constraints live in the space,                         (ie, they have collection data)
# it's necessary to contain them in a collection for updating
# this collection should probably be linear, so it enforces a strict update order


# also, constraints should probably not be considered Entity objects,
# even if they have physics data...
# * they do not use physics data in the same way
#    they do not collide with Entity types (this is separate from Entity / Query objects)
# * they do not respond to Entity actions like Move in the same way











parameterized = Array.new
wrappers      = Array.new
active        = Array.new

i = 0




parameterized[i] = ConstraintClosure.new


pointer   = PointerWrapper.new(parameterized, i)

active[i] = [[LimitHeight, pointer], DrawEdge, Directed]

i += 1

# NOTE: it's the active constraints that need to be 'updated' and maintained in a particular order. One active constraint triple may link to the same Constraint object that is used by various different relations
# (when I say 'relation' I mean one group with an iterator, such as one pair of constrained Entity objects)

# again: one constraint object may be used in multiple places



i = 0
parameterized[i]
	.let :a => 0.8 do |vars, h|
		# 0.8*h
		vars[:a]*h
	end




# this thing goes inside of a constraint, modifying particular values
class ConstraintClosure
	attr_reader :vars
	
	def initialize
		
	end
	
	def let(vars={}, &block)
		@vars = vars
		@block = block
	end
	
	def call(*args)
		@block.call @vars, *args
	end
	alias :[] :call
end


# if you were to copy a constraint link exactly,
	# you would want to point to the same constraint object
# if you were to copy just the type of the constraint link,
	# you want to create a new constraint object, parameterizing it with a new closure that is an exact copy of the first closure
	# basically, you want a deep copy
# if you create a new constraint link from a base type,
	# you would need to return to the basic step of declaring a parameterization, if the constraint can be parameterized



# so, three options:
	# copy pointer to Constraint object,
	# deep copy
	# create new parameter and load it into the constraint

# notice that shallow copy seems to be missing
# ie) this system will not allow you to link only the parameter, but not the Constraint object
# which I think is proper
# because two Constraint objects with the same parameterization should do exactly the same thing
# because Constraint objects store no state, other than their parameterization











# This means two Constraint links are either going to be exactly the same data,
# or the same Constraint object type with different (but equivalent) parameter objects
# (describing only equivalent pairs here, not any two pairwise constraints. hope that's clear)
# 
# This means that the Constraint object pointers in the 'parameterized' list will always be unique


parameterized = Array.new
active        = Array.new





i = parameterized.size



p = ConstraintClosure.new
constraint = LimitHeight.new(p)

parameterized << constraint

active        << [constraint, DrawEdge, Directed]




parameterized[i].closure
	.let :a => 0.8 do |vars, h|
		# 0.8*h
		vars[:a]*h
	end




# this thing goes inside of a constraint, modifying particular values
class ConstraintClosure
	# NOTE: assuming that all variable parameters are pieces of data unique to this object. If pass in a string, that string better never get modified anywhere else.
	# (I should probably make a copy of those sorts of things, but I'm not quite sure how to do that right now)
	# (that would be a much less brittle interface, and I think there are libraries that do that)
	attr_reader :vars
	
	def initialize
		
	end
	
	def let(vars={}, &block)
		@vars = vars
		@block = block
	end
	
	def call(*args)
		@block.call @vars, *args
	end
	alias :[] :call
	
	
	# return a deep copy of this object
	# TODO: need to make sure that this is sound. Pretty sure it's not, right now.
	def clone
		obj = self.class.new
		
		
		v = @vars.clone
		b = @block.clone
		
		obj.instance_eval do
			@vars  = v
			@block = b
		end
		
		
		return obj
	end
end


# consider that maybe all constraints should have a ConstraintObject inside them
# so that they can have parameters that are exposed to the graph editor?
# Would make the external calling interface even cleaner,
# because you wouldn't have to pass in a parameter object.
# 
# Remember again, that you never link to another constraint object's parameter data.
# Thus, it's not really that important to be able to pass in a parameter.