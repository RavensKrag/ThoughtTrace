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


class Query < Entity
	def initialize(shape, *shape_args)
		super()
		
		
		# should be allowed to have queries of different shapes though...
		
		# TODO: Update geometry when style is updated, and vice versa. (or else maybe width and height shouldn't be stored in Style)
							body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
							shape = CP::Shape::Circle.new body, style[:radius]
		add_component	ThoughtTrace::Components::Physics.new self, body, shape
		
		
		
		
		
		
		case shape
			when :circle
				
			when :rectangle
			
			when :
		end
		
		# need to pair shape with proper resize action
		
		{
			CP::Shape::Circle => ThoughtTrace::Actions::ResizeCircle,
			CP::Shape::Rect => ThoughtTrace::Actions::ResizeRectangle,
			CP::Shape::Text => ThoughtTrace::Actions::ResizeText
			# text is not a shape type...
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
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




# Try transforming Entity into query instead

def create_query(entity)
	# wait, this is unnecessary when the entity already exists....
		# need to pair shape with proper resize action
		
		action_mapping = {
			ThoughtTrace::Circle    => ThoughtTrace::Actions::ResizeCircle,
			ThoughtTrace::Rectangle => ThoughtTrace::Actions::ResizeRectangle,
			ThoughtTrace::Text      => ThoughtTrace::Actions::ResizeText
		}
		
		
		# can condense that into logic
		# based on naming convention of Entities and associated Actions
		resize_class = ThoughtTrace::Actions.const_get "Resize#{entity.class.name}"
		
		resize_action = resize_class.new entity
	
	
	
	# but now you have to add a component externally
	# I mean...
	# this is permissible with the current API,
	# but idk if it's wise?
	# but it's not like you can ever delete components, so I suppose that's ok?
	entity.add_component Query.new entity
	
	# but I think you may need to remove the Query attribute on things occasionally
	# it's not really an innate property
	# but something that an Entity might have
	# or might not have
end



# Query as a wrapper of Entity

class Query
	# use bind / unbind because hijacking the destructor in Ruby is really weird
	# side effect: one query can easily be passed around between different Entity objects
			# no need to delete and re-create
	# also, this means that the initialization of Queries feels like Action / Component
	
	def initialize(space)
		@@collision_handler ||= CollisionHandler.new
		@@collision_type ||= :query
		
		
		@space = space
	end
	
	
	
	
	
	def update
		
	end
	
	def draw
		# the main Entity may already be drawn
		# this should render only the information specific to viewing the Query
		
		# or put another way, it should render for the Query view
	end
	
	
	
	
	
	# connect an Entity to this query
	# TODO: figure out if binding multiple Entities to one Query is permissible or not
	# NOTE: currently, only one Entity can be bound at a time
	def bind(entity)
		# start
		raise "#{self} already has one Entity bound to it." if @bound_entity
		raise_errors_if_depencies_unmet entity
		
		@bound_entity = entity
		
		
		# body
		# Establish collision callbacks between any Entity, and any Query
		# The collision handler is written very generally
		# Specifics are delegated to each Query object
		
		# clobbering of collision handlers is acceptable, as it's always the same handler object
		# it is a bit inefficient though
		
		# NOTE: This style allows for Entities with diverse collision_type properties. If the collision type of each Entity is always going to be the same, this step can be performed once in #initialize, rather than being performed on each bind.
		@space.add_collision_handler(
			@@collision_type,
			@bound_entity[:physics].shape.collision_type,
			
			@@collision_handler
		)
		
		@bound_entity[:physics].shape.sensor = true
		
		# cleanup
		
		return self
	end
	
	# Remove the linkage between the Query an it's Entity
	# NOTE: if multiple Entities can be bound to one Query, you should only unbind one. In that case, you would need to specify which Entity you want unbound.
		# I suppose you could take zero args to unbind all?
		# but unbind all is a rather different sort of procedure, so it should be it's own thing
	def unbind
		# start
		
		
		
		# body
		# TODO: consider restoring the shape's previous sensor status instead of forcing false
		@bound_entity[:physics].shape.sensor = false
		
		
		# cleanup
		@bound_entity = nil
		
		return self
	end
	
	
	
	
	
	
	
	# ===== callbacks for particular query events =====
	# called once when the Query first detects an Entity
	def on_add(entity)
		
	end
	
	# called every tick while the Query is aware of the Entity
	def on_tick(entity)
		# maybe this should be in #update?
		# maybe #update should only be for updating the Query itself?
		
	end
	
	# called once when the Query first loses track of an Entity
	def on_remove(entity)
		
	end
	
	
	
	
	
	
	
	# add / remove things from the set of things to be queried
	class CollisionHandler
		def begin(arbiter)
			query_object, entity = parse_arbiter(arbiter)
			
			if true # some condition for collision
				query_object.on_add entity
				
				
				return true
			else 
				return false
			end
		end

		def pre_solve(arbiter)
			query_object, entity = parse_arbiter(arbiter)
			
			query_object.on_tick entity
		end

		# def post_solve(arbiter)
		# 	query_object, entity = parse_arbiter(arbiter)
			
			
		# end

		def separate(arbiter)
			query_object, entity = parse_arbiter(arbiter)
			
			query_object.on_remove entity
		end
		
		
		private
		
		
		def parse_arbiter(arbiter)
			query_object = arbiter.a.obj
			entity       = arbiter.b.obj
			
			
			return query_object, entity
		end
	end
	
	
	private
	
	def raise_errors_if_depencies_unmet(entity)
		[
			:physics
		].each do |component_name|
			unless entity[component_name]
				raise "#{entity} does not have a #{component_name.to_s.capitalize} component"
			end
		end
	end
end