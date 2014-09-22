module ThoughtTrace
	module Components



class Query < Component
	interface_name :query
	components :physics, :style
		
	attr_reader :callbacks
	
	def initialize(style, callbacks)
		super()
		
		@style = style         # one style object that defines the visual appearance of all queries
		@callbacks = callbacks # object defining a set of callbacks
		# depends on Space, but that reference will be passed to the callbacks as necessary
		
		
		# style is used to visually mark queries
		# callbacks are accessed through the query component
		# ex) entity[:query].callbacks
		# 
		# (or for a specific example)
			# entity[:query].callbacks.on_add
	end
	
	
	
	
	
	
	
	
	# use bind / unbind because hijacking the destructor in Ruby is really weird
	# side effect: one query component can easily be passed around between different Entity objects
			# no need to delete and re-create
	
	
	
	# connect an Entity to this query
	# TODO: figure out if binding multiple Entities to one Query is permissible or not
	# NOTE: currently, only one Entity can be bound at a time
	
	# NOTE: to bind multiple entities to the same callback item (to preserve state among many entities) please connect one query callback object -> many query components -> each with their own Entity objects.
	# Separating the management of binding from the callbacks makes things much clearer.
	
	def on_bind(entity)
		super(entity)
		
		# ===== body
		# -- physics
			# Establish collision callbacks between any Entity, and any Query
			# The collision handler is written very generally
			# Specifics are delegated to each Query object
			
			
			@defaults = {
				:sensor =>         entity[:physics].shape.sensor?,
				:collision_type => entity[:physics].shape.collision_type
			}
			
			
			entity[:physics].shape.collision_type = ThoughtTrace::Queries::COLLISION_TYPE
			entity[:physics].shape.sensor = true
			
			
			
			
		# -- style
			# rather than storing the current style mode for later, the unbind callback will simply make sure that the query style mode is not currently in use, and replace with the default mode if necessary
			
			
			entity[:style].tap do |component|
				default_cascade = component.cascade(:default)
				
				
				component.edit(:query) do |x|
					x.socket(1, @style)
					x.socket(2, default_cascade)
				end
				
				component.mode = :query
			end
			
			
			# with this structure, the query style will always cascade into the default style, even if the default style changes after the binding of the Query to the Entity
			
			# apply yet another style instead of just modifying the default style for the new mode
			# two reasons:
			# 1) allows easy modification of a bunch of objects through one style
			# 2) can modify one Query object independently of the others if you need to (sketching etc)
			# (these are both really two aspects of the same thing)
		
		
		# ===== cleanup
		
		return self
	end
	
	
	# Remove the linkage between the Query an it's Entity
	# NOTE: if multiple Entities can be bound to one Query, you should only unbind one. In that case, you would need to specify which Entity you want unbound.
		# I suppose you could take zero args to unbind all?
		# but unbind all is a rather different sort of procedure, so it should be it's own thing
	
	def on_unbind(entity)
		super(entity)
		
		# ===== body
		# -- physics
			# restore chipmunk properties
			entity[:physics].shape.sensor         = @defaults[:sensor]
			entity[:physics].shape.collision_type = @defaults[:collision_type]
		# -- style
			# eliminate the Query formatting style mode from the cascade
			# and make sure that it is not actively being used to render the Entity
			current_style_mode = entity[:style].mode
			
			if current_style_mode == :query
				entity[:style].mode = :default
			end
			
			# do you really want the query style as a new mode? do you not want it to cascade into the other styles defined for the Entity?
			
			# TODO: need method to purge a particular style mode from the Style Component
			entity[:style].delete :query
			
		
		
		# ===== cleanup
		# entity = nil
		
		return self
	end
end


end
end