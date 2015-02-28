Closure
	@proc
	@vars
	def call(*args) => @proc.call(@vars, *args)

Constraint
	# closure is bound to one type of constraint
	# cache is bound to one pair
	# closure vars are bound to one closure instance
	@closure
	def foo(a,b)
	def call(closure, a,b, cache)

Cache
	@prev
	@this
	def bar?(cache)
	def save(cache, data)

Visualization
	def draw(a,b)
	def update

Pair
	@a
	@b
	@cache
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

Standard
	# all data
	@pair
	@visualization    (optional)
	@marker_a         (optional)
	@marker_b         (optional)
	def bind(a,b) => @pair
	def update
	def draw      => @visualization
	# markers are Entities and will be rendered with other entities
Headless   < Standard
	no visualization
Abstracted < Standard
	no markers
Optimized  < Standard
	no visualization
	no markers
	# this is essentially just a pair, but it has stubs for the Standard interface stuff