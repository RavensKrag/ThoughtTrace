class Entity
	def initialize
		
	end
end





# controls overall flow
class Bar
	def initialize(space)
		@space = space
	end
	
	# start operation
	def press(point)
		list = @space.point_query(point, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil)
		
		# get some desirable element out of the query
		entity = list.first
		
		
		foo = entity.foo
		@foo = foo
		@foo.press(point)
	end
	
	# adjust operation interactively
	def hold(point)
		@foo.hold(point)
	end
	
	# complete operation
	def release(point)
		@foo.release(point)
	end
	
	# revert to the state before this structure was invoked
	def cancel
		@foo.cancel
	end
end

# controls specific implementation
class Foo
	def initialize(space, stash, entity)
		@space = space
		
		@stash = stash
		@entity = entity
	end
	
	def press(point)
		
	end
	
	def hold(point)
		
	end
	
	def release(point)
		
		
		return Baz.new()
	end
	
	def cancel
		
	end
end

# allows for undo/redo
class Baz
	def initialize(entity, method, *args)
		@entity = entity
		@method = method
		@args = args
	end
	
	def forward
		@entity.send :method, *@args
	end
	
	def reverse
		# trigger process to reverse method
	end
end


class Kad
	def initialize(space, stash, entity)
		@space = space
		
		@stash = stash
		@entity = entity
	end
	
	def press(point)
		
	end
	
	def hold(point)
		
	end
	
	def release(point)
		
		
		return Baz.new()
	end
	
	def cancel
		
	end
end










class Circle < Entity
	# wrapping backend methods seems trivial for radius alteration,
	# but makes sense for things like rectangle rescaling
	# which require a lockdown point
	# or text scaling, in which height and width are conjoined
	# May want to just wrap everything for the sake of a unified interface.
	def radius
		@components[:physics].shape.radius
	end
	
	def radius=(r)
		@components[:physics].shape.set_radius! r
	end
	
	
	action ResizeCircle
end

class ResizeCircle < Foo
	# TODO: all Foo should have a #draw as well, to visually display information to the user
	
	def initialize(space, stash, entity)
		@space = space # for queries and modifications to the space (ex, new objects)
		
		@stash = stash # for passing control to other Foo objects for chaining actions
		@entity = entity
	end
	
	def press(point)
		super(point)
		
		# mark the initial point for reference
		@origin = point
		
		@original_radius = @entity.radius
	end
	
	def hold(point)
		super(point)
		
		# Alter the size of the circle by an amount equal to the radial displacement
		# Away from the center is positive,
		# towards the center is negative.
		
		displacement = point - @origin
		
		# project displacement along the radial axis
		center = @entity[:physics].body.p.clone
		r = (point - center).normalize
		
		radial_displacement = displacement.project(r)
		magnitude = radial_displacement.length
		
		# flip sign if necessary
		magnitude = -magnitude unless displacement.dot(r) > 0
		
		
		
		# limit minimum size
		radius = @original_radius + magnitude
		radius = MINIMUM_DIMENSION if radius < MINIMUM_DIMENSION
		
		
		
		
		@memo = Memento.new(@entity, @original_radius, radius)
		@memo.forward
	end
	
	def release(point)
		super(point)
		
		return @memo
	end
	
	def cancel
		super()
		
		# the memo is always created during the #hold phase
		# so, if there is no @memo, no #hold has been executed yet
		# this means that no change has yet been made to the @entity
		# thus, nothing needs to be reversed
		# (more importantly, nothing can be reverted without the @memo)
		@memo.reverse if @memo
	end
	
	
	
	
	# perform the transformation here
	# by encapsulating the transform in this object,
	# it becomes easy to redo / undo actions as necessary
	# (Consider better name. Current class name derives from a design pattern.)
	# (this class also has ideas from the command pattern, though)
	class Memento
		# TODO: insure that #forward and #reverse maintain the redo / undo paradigm. Currently, you could run #forward twice in a row, to apply the operation twice. That's not desirable.
		def initialize(entity, past, future)
			@entity = entity
			
			@past = past     # encapsulates the condition before execution
			@future = future # encapsulates condition after execution
		end
		
		# set future state
		def forward
			@entity.radius = @future
		end
		
		# set past state
		def reverse
			@entity.radius = @past
		end
	end
end











class Foo
	# TODO: all Foo should have a #draw as well, to visually display information to the user
	
	def initialize(space, stash, entity)
		@space = space # for queries and modifications to the space (ex, new objects)
		
		@stash = stash # for passing control to other Foo objects for chaining actions
		@entity = entity
	end
	
	# outer API
	# used to give external code something to call
		def press(point)
			setup(point)
		end
		
		def hold(point)
			# IMPLEMENTATION core
			past, future = update(point)
			
			# MEMO creation (pseudo return)
			@memo = Memento.new(@entity, past, future)
			@memo.forward
		end
		
		def release(point)
			return @memo
		end
		
		def cancel
			# the memo is always created during the #hold phase
			# so, if there is no @memo, no #hold has been executed yet
			# this means that no change has yet been made to the @entity
			# thus, nothing needs to be reversed
			# (more importantly, nothing can be reverted without the @memo)
			@memo.reverse if @memo
		end
	
	
	
	
	# inner API
	# separate from outer API so that you don't have to think about
	# creating or managing memos in child class implementation
		# called on first tick
		def setup(point)
			
		end
		
		# return two values: past and future used by Memento
		# called each tick
		def update(point)
			
		end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw(point)
		
	end
	
	
	
	# perform the transformation here
	# by encapsulating the transform in this object,
	# it becomes easy to redo / undo actions as necessary
	# (Consider better name. Current class name derives from a design pattern.)
	# (this class also has ideas from the command pattern, though)
	class Memento
		# TODO: insure that #forward and #reverse maintain the redo / undo paradigm. Currently, you could run #forward twice in a row, to apply the operation twice. That's not desirable.
		def initialize(entity, past, future)
			@entity = entity
			
			@past = past     # encapsulates the condition before execution
			@future = future # encapsulates condition after execution
		end
		
		# set future state
		def forward
			
		end
		
		# set past state
		def reverse
			
		end
	end
end