

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
		
		if baz?(@cache, data)
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
	def baz?(cache, data)
		# return the truth value specified by 'data' if 'data' is a boolean, ignoring the cache
		return data if !!data == data
		
		
		# there is stored data but it's old, or no data has yet been stored
		cache && cache != data or cache.nil?
	end
end



class Constraint
	def initialize
		
	end
	
	
	
	# this thing goes inside of a constraint, modifying particular values
	class Closure
		attr_reader :vars
		
		def initialize
			
		end
		
		def let(vars={}, &block)
			@vars = vars
			@block = block
		end
		
		# should be able to deal with the case of having no block
		def call(*args)
			if @block
				# run sub-transform as defined by this closure
				return @block.call @vars, *args
			else
				# return unmodified data
				return *args
			end
		end
		alias :[] :call
		
		
		# return a deep copy of this object
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
		
		
		# remove binding block
		def clear
			@block = nil
		end
	end
end



# GUI will display a list of parameterized constraints,
# similar to how the Blender GUI shows a list of the currently active materials.
# This class forms the backend for that list.
class ResourceList
	# tracked object, resource count, gc when count is zero? (on close, etc)
	Data = Struct.new(:resource, :count, :removal_flag)
	
	
	def initialize
		@storage = Array.new
	end
	
	def push(resource)
		@storage << Data.new(resource, 1, true)
	end
	
	def each(&block)
		@storage.each &block
	end
	
	def find(resource)
		@storage.find{ |x| x.resource.equal? resource  }
	end
	
	# (might not need this)
	def count_for(resource)
		self.find(resource).count
	end
	
	
	
	
	
	
	
	# make it so that constraints will not be removed, even when they have 0 users
	# 
	# (Blender: F button)
	def lock(i)
		@storage[i].removal_flag = false
	end
	
	# opposite of #lock
	def unlock(i)
		@storage[i].removal_flag = true
	end
	
	# duplicate one item, and store it as a new resource
	# 
	# (Blender: + button)
	def duplicate(i)
		self.push @storage[i].resource.clone
	end
	
	# remove a particular resource from the list
	# NOTE: this should probably also purge it from the system. (remove from all objects that use this resource) Not sure how to implement that
	# not sure if this command is necessary
	# 
	# (Blender: - button)
	def delete_at(i)
		@storage.delete_at i
	end
	
	
	# provide a pointer to the resource, and increment the count
	# TODO: needs better name
	def use(i)
		data = @storage[i]
		data.count += 1
		
		return data.resource
	end
	
	# given a pointer to a resource, decrement the count because we're done with it now
	# TODO: needs better name
	def stop(resource)
		data = self.find(resource)
		data.count -= 1
		
		if data.count < 0
			raise "Freed data where you shouldn't have. Can't have negative resource count." 
		end
	end
	
	
	
	
	
	
	
	
	def gc
		@storage.reject! do |data|
			data.removal_flag and data.count == 0
		end
	end
end

















# all constraints should have ConstraintClosures attached, even if they end up being vestigial.
# Each constraint type will decide on it's own whether to pass data through the closure,
# so constraint types that don't use it will only waste space, not time.
# This is still inefficient, but that sort of thing can be optimized out later,
# during the graph system build phase
# (that's still a long ways away from being written... but still)

# === setup
parameterized = ResourceList.new
active        = Array.new




# === generate a new constraint

constraint = LimitHeight.new



parameterized.push constraint
# TODO: maybe count the number of active slots are using this constraint object? would be useful for seeing which constraints are in demand, and which ones are currently not being used at all... etc



# active        << [constraint, Directed, DrawEdge]
package = ConstraintPackage.new(constraint, DrawEdge)
active << package



package.constraint.closure
	.let :a => 0.8 do |vars, h|
		# 0.8*h
		vars[:a]*h
	end

# NOTE: in production code, the entities will be bound in the graphical interface, not directly in this part of the code
package.bind_source_entity e1
package.bind_sink_entity   e2






# === use existing constraint

constraint = parameterized.use(i)




package = ConstraintPackage.new(constraint, DrawEdge)
active << package



package.constraint.closure
	.let :a => 0.8 do |vars, h|
		# 0.8*h
		vars[:a]*h
	end

# NOTE: in production code, the entities will be bound in the graphical interface, not directly in this part of the code
package.bind_source_entity e1
package.bind_sink_entity   e2








# === delete a constraint

package = active[i]
constraint = package.constraint

parameterized.stop(constraint)












# refresh this cached selection on occasion
# (idk if this way is any "better")

# it's important to know if you want to keep parameterized constraints
# even when they don't have any active users.
# Blender does this with materials.
# It's often useful during the process of creation, even if it's not critical to the end product.
parameterized = active.collect{|x|  x.constraint }.uniq