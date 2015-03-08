# data linkage tree
# (not necessarily the same as class nesting or class hierarchy)
Package                        # basic types
	Pair
		[@a, @b]
		Cache
		Constraint
			Closure
	Visualization
	Marker (x2)

BackendCollection              # collections
	Constraint
PackageCollection
	Package

# NOTE: collections 'unpack' into existing collections, while basics type return a new object



# class descriptions
BackendCollection  # stores raw constraint objects, mapped by UUIDs
PackageCollection # stores full constraint packages, in a linear collection

Closure
	@proc
	@vars
	def call(*args) => @proc.call(@vars, *args)
	def let(vars={}, &block)
	def clear
	def clone

Constraint
	# closure is bound to one type of constraint
	# cache is bound to one pair
	# closure vars are bound to one closure instance
	@closure
	def foo(a,b)
	def call(closure, a,b, cache)
	def clone

Cache # for a low-level implementation, this needs to be a generic ie: Cache<T>
	@prev
	@this
	def bar?(cache)
	def save(cache, data)
	def clear

Visualization
	def draw(a,b)
	def update

Pair
	@a          # ptr
	@b          # ptr
	@cache      # direct data
	@constraint # ptr
	def bind(a,b)
	def unbind
	
	def update(&block)
		return if @a.nil? or @b.nil?
		
		@cache.save(@constraint.foo(@a,@b))
		
		if @cache.bar?
			@constraint.call(@a,@b,@cache)
			@cache.save(@constraint.foo(@a,@b))
			
			block.call
		end
	end

Marker
	@constraint_target  (Entity) # ptr
	@render_target      (Entity) # ptr
	def bind_to(entity)
	def unbind

# NOTE: not sure if all Package types should have the same data format, to try for fixed schema?
# (I don't think that works because of Cache being basically a Java generic collection)
Package # interface
	def update    => @pair.bind(a,b)
	def draw
Standard   < Package
	# all data
	@pair
	@visualization    (optional)
	@marker_a         (optional)
	@marker_b         (optional)
	def update    => @pair.bind(a,b) # uses markers to automatically acquire bindings
	def draw      => @visualization
	# markers are Entities and will be rendered with other entities
Headless   < Package
	no visualization
Abstracted < Package
	no markers
Optimized  < Package
	no visualization
	no markers
	# this is essentially just a pair, but it has stubs for the Standard interface stuff