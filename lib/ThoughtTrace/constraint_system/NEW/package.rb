# bind up a reusable constraint 'function' thing, a visualization, and two entity handles,
# along with some cache space.
# Always describes a constraint between two entity objects.
class ConstraintPackage
	def initialize(constraint_obj, visualization)
		@constraint      = constraint_obj
		@visualization   = visualization
		
		@entity_marker_1 = EntityMarker.new
		@entity_marker_2 = EntityMarker.new
		
		@cache = nil
		# NOTE: in optimized implementation, should figure out what type this is going to be at compile-time, and allocate enough space for it here. That way, the cache lookup is made faster due to data locality.
		# NOTE: if a bunch of these constraint wrappers are allocated in a pool, you could allocate space for the unknown @cache field to be equal to the largest possible cache. possible use of 'unions' (related to structs) if implementing in C.
			# ie) constraint, vis, e1, e2,  32 bytes
			#     constraint, vis, e1, e2,  12 bytes
			#     constraint, vis, e1, e2, 100 bytes
		
		
		
		
		
		
		# TODO: get the Entity markers to snap as they are moved
		
		
		
		
		# Want to keep the tracking markers positioned relative to the centers of the related entities
		# also, all the tracking objects on one entity should repel each other, so that you can more easily select them with the mouse (may have to do that logic inside of the collider callback?)
		# NOTE: update to use actual constraints. the constraint declaration here is just a demo
		
		@move_with = Constraints::MoveWith.new
		# TODO: in the future, consider implementing constraints as closures with closure bound variables, rather than objects (would need a language that isn't Ruby to do that sort of implementation though)
	end
	
	
	def update
		# extract entities from tracker objects
		a = @entity_marker_1.entity
		b = @entity_marker_2.entity
		
		return if a.nil? or b.nil?
		
		
		# apply constraint tick if necessary
		data = @constraint.foo(a,b)
		
		if fire_constraint?(@cache, data)
			@constraint.call(a,b)
			@cache = data
			
			
			@visualization.activate
		end
		
		
		# use helper constraints to update the entity markers
		if @visible # don't update position of markers, unless markers are going to be drawn
			@move_with.call(@entity_marker_1, a)
			@move_with.call(@entity_marker_2, b)
		end
	end
	
	def draw
		return if not @visible # allow hiding the visualization (useful for optimization)
		
		a = @entity_marker_1.entity
		b = @entity_marker_2.entity
		
		return if a.nil? or b.nil?
		
		# TODO: figure out how to visualize the constraint when entities are not bound. Need to draw it somehow, or you will not be able to see it when nothing is bound, and then how will you bind things graphically?!? (That's a big mess, is what that is)
		
		@visualization.draw_inactive(a,b)
	end
	
	
	
	
	private
	
	# check the cache
	# return true if the constraint needs to be run again
	def fire_constraint?(cache, data)
		# return the truth value specified by 'data' if 'data' is a boolean, ignoring the cache
		return data if !!data == data
		
		
		# there is stored data but it's old, or no data has yet been stored
		cache && cache != data or cache.nil?
	end
end






# part with the caching
# doesn't handle any visualization at all, just the raw constraint data.
# Don't want to ever use this normally, but maybe you can substitute it in the build phase as an optimization?
class HeadlessStaticConstraintWrapper
	def initialize(constraint, a,b)
		@constraint = constraint
		@a = a
		@b = b
		
		@cache = nil
	end
	
	def update
		# apply constraint tick if necessary
		data = @constraint.foo(@a,@b)
		
		if baz?(@cache, data)
			@constraint.call(@a,@b)
			@cache = data
			
			return true
		end
		
		return false
	end
	
	
	
		
	
	
	
	private
	
	# check the cache
	# return true if the constraint needs to be run again
	def baz?(cache, data)
		# return the truth value specified by 'data' if 'data' is a boolean, ignoring the cache
		return data if !!data == data
		
		
		# there is stored data but it's old, or no data has yet been stored
		cache && cache != data or cache.nil?
	end
end