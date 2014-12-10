
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




parameterized[i] = Foo.new



active[i]        = [[LimitHeight, PointerWrapper.new(parameterized, i)], DrawEdge, Directed]

i += 1







parameterized[pointer.i]
	.let :a => 0.8 do |vars, h|
		# 0.8*h
		vars[:a]*h
	end




# this thing goes inside of a constraint, modifying particular values
class Foo
	def initialize
		
	end
	
	def let(&block)
		
	end
	
	
	
	def call()
		
	end
	alias :[] :call
end