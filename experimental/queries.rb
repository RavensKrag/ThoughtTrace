=begin

need to be able to easily plop down queries
	just an human interface problem?


are queries a type of entity?
	they have physics component, but they don't have the actions of an Entity

with no actions, should the Physics component should be used?
something with the same interface?
a rejuggling of the basic Chipmunk facilities?


but queries need to be resized and moved the same way Entities are
or at least the actions need to feel the same
so maybe they're the same thing?

	consider how the queries are resized
	consider if the Entity actions can provide proper callbacks for resizing
	if it is necessary for Queries to be notified of such a thing
		
		TEST THIS OUT
		what happens to collisions if a shape is resized?
		will the resulting overlap / removal of overlap be evaluated correctly?
		it should be - just happens on the next physics space tick


build on physics collisions with sensor objects more than Chipmunk queries

=end


class Query
	def initialize
		# physics = ThoughtTrace::Components::Physics.new
		
		@body = body
		@shape = shape
		@shape.obj = parent
		# still necessary to bind Query object to shape
		# because the collision callback needs to know about this object
		
		
		
		
		# TODO: bind the specific query logic to the collision callback associated with the shape associated to this object
		
		
		@collision_handler = CollisionHandler.new(self)
		@shape.collision_type = :query
		
		
		# not sure if multiple query collision types should be defined
		# not sure if collision handler objects should be established for each query instance
			# this would allow for unique query behavior in the collision handler object
			# but would mean that the current code will not work
				# the current code assigns a new collision handler when this object is added to space
				# kinda assumes that each query object is totally separate
					# not even 'collision_type' field overlaps
					# if the 'collision_type' does overlap, then the handlers will clobber
					# and the active handler will be the one added last
		
		# --- define big types for collisions, like :entity, :query, etc
		# only one or two big labels
		# delegate specifics to each object, rather than resolving in the collision handler
			# define custom names for specific phases, rather than using the chipmunk phases
		
		# or you could even have the "big collision handler" delegate to a "smaller" collision handler object inside each object
			# ex) CollisionHandler#pre_solve --> object.collision_handler.pre_solve
		
		
		# --- create types for each type of collision, very specifically
		# each type of entity or query would have it's own collision type
		# that would kinda be a pain to manage what handlers are active
		# handlers can be subclassed to share functionality
			# all entity handlers are descended from one class
			# (uses natural Ruby structure, instead of "big collision" mode which wraps delegates)
		
		
		
		
		
		
		
		# should be using groups or layers potentially to do broad culling
		
		
		
		
		
		# moves like an entity
		# resizes like an entity
		# occupies "physical" space like a entity
		# (is it really an entity?)
		# (or should it just be implemented that way for convenience?)
		# (does it matter?)
	end
	
	def update
		
	end
	
	def draw
		
	end
	
	
	
	
	def add_to(space)
		# the chipmunk function requires two names:
		# one for each shape that is colliding
		
		# but queries need to collide with all entity types
		
		# not sure if they need to define collision with many types
		# or only only collision type will be used for all entities
		
		space.add_collision_handler @shape.collision_type, :entity, @collision_handler
		
	end
	
	
	class CollisionHandler
		def initialize(object)
			@object = object
		end
		
		
		
		def begin(arbiter)
			
		end

		def pre_solve(arbiter)
			
		end

		def post_solve(arbiter)
			
		end

		def separate(arbiter)
			
		end
	end
end