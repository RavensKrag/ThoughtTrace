module TextSpace
	class Space < CP::Space
		def initialize
			@objects =	Array.new
			
			
			# set variables needed for physics space
			# iteration constants, etc
			@dt = 1.0/60
			
			super()
		end
		
		def update
			@objects.each do |obj|
				obj.update
			end
			
			step(@dt)
		end
		
		def draw
			@objects.each do |obj|
				obj.draw
			end
		end
		
		def empty?
			@objects.empty?
		end
		
		def add(object)
			raise "Physics component on #{object.inspect} not found." unless object.respond_to? :physics
			
			@objects << object
			
			add_shape(object.physics.shape)
			add_body(object.physics.body)
		end
		
		def merge(enum)
			enum.each do |obj|
				self.add obj
			end
			
			# enum.each &:add
		end
		
		def delete(object)
			
		end
		
		
		
		
		def delete_if_empty(object)
			# TODO: Should be able to remove nil check on string.
			@objects.delete object if object.string == nil || object.string.strip.empty?
		end
		
		# Clean up unnecessary objects
		# ie, empty strings
		def gc
			@objects.delete_if do |obj|
				# TODO: Perform GC without having to check for specific types. Should be using polymorphism.
				if obj.is_a? TextSpace::Text
					obj.string == nil || obj.string.strip.empty?
				else
					false
				end
			end
		end
		
		
	#    ____                  _          
	#   / __ \__  _____  _____(_)__  _____
	#  / / / / / / / _ \/ ___/ / _ \/ ___/
	# / /_/ / /_/ /  __/ /  / /  __(__  ) 
	# \___\_\__,_/\___/_/  /_/\___/____/  
	# Most queries can take a set parameter, which limits the selection
	# to some subset of the objects in the Space.
	# Could be anything that implements #include? but Set is preferable for performance reasons.
		def empty_at?(position)
			selection = point_query(position, CP::ALL_LAYERS, CP::NO_GROUP)
			
			return selection.empty?
		end
		
		
		
		# in the same way queries are limited by layer and group, limit by a selection set
		# (could really be anything that implements #include? but Set would be best)
			
		# add "set=nil" to all parameter lists
		
		
		
		# Query the space, finding all shapes at the point specified.
		# Returns a list of the objects attached to the discovered shapes.
		# Each object will only appear once within the list.
		# Query does not make any guarantees about the order in which objects are returned.
		# TODO: adjust API so accepting block is not necessary (method chaining is more flexible)?
		def point_query(point, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil, &block)
			# block params: |object_in_space|
			
			selection = []
			super(point, layers, group) do |shape|
				selection << shape.obj
			end
			
			selection.uniq!
			
			
			selection = limit_selection(selection, set)
			
			
			selection.each &block if block
			
			return selection
		end
		
		def point_query_first(point, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil)
			# this method can not be modulated by the selection set if it uses a super() call
			# may just avoid implementing a new version of this, and fall back on parent version,
			# as #point_query_best is better when you just want one object
		end
		
		# same as point_query_first
		# def shape_point_query
			
		# end
		alias :shape_point_query :point_query_first
		
		# new!
		# builds on the definition of #point_query above,
		# so you do not need to explicitly limit the selection again in this method
		def point_query_best(point, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil)
			# TODO: Should short circuit when selection becomes empty
			# TODO: Short circuit on selection size of 1? (Only after initial bb query)
			
			# Select objects under the mouse
			# If there's a conflict, get smallest one (least area)
			
			# There should be some other rule about distance to center of object
				# triggers for many objects of similar size?
				
				# when objects are densely packed, it can be hard to select the right one
				# the intuitive approach is to try to select dense objects by their center
			
			
			
			# TODO: Re-write as loop of sorting and testing selection size
			# removes "selection = selection.method" noise in defining sorts
			# better illustrates cyclical flow
			
			
			
			# Initial query
			selection = self.point_query(point, layers, group, set)
			
			return nil if selection.empty?
			
			selection.sort! do |a, b|
				a.physics.shape.area <=> b.physics.shape.area
			end
			
			# Get the smallest area values, within a certain threshold
			# Results in a certain margin of what size is acceptable,
			# relative to the smallest object
			selection = selection.select do |o|
				# TODO: Tweak margin
				size_margin = 1.8 # percentage
				
				first_area = selection.first.physics.shape.area
				o.physics.shape.area.between? first_area, first_area*(size_margin)
			end
			
			selection.sort! do |a, b|
				# Assuming that the shapes all have their center on their local origin
				distance_to_a = a.physics.body.pos.dist point
				distance_to_b = b.physics.body.pos.dist point
				
				# Listed in order of precedence, but sort order needs to be reverse of that
				[a.physics.shape.area, distance_to_a].reverse <=> [b.physics.shape.area, distance_to_b].reverse
			end
			
			return selection.first
		end
		
		# if only the first two arguments are given,
		# 	returns a CP::SegmentQueryInfo struct with the results of the query
		# 	shape:	shape that was hit
		# 	t:		distance down the segment, 0..1
		# 	n:		Normal of hit surface
		# if all arguments given
		# 	block called for the shape that is found
		# 	(implication that all matches are returned)
		# NOTE: includes sensor shapes
		# 
			# preserve old version, for use with #segment_query_first (rationale @ that method)
			alias :old_segment_query :segment_query
		# 
		# This iterates over all shapes, not all objects, as opposed to the point query.
		# This is to preserve the distances an normals of the collisions.
		# The objects can still be accessed through the shapes, so it's not a big deal.
			# Though, it may be what you want most often when you do this sort of thing,
			# so having to go through the shape may introduce unwanted noise to the code.
		def segment_query(start, stop, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil, &block)
			# block params: |shape, t, n|
			super(start, stop, layers, group) do |shape, t, n|
				block.call(shape, t, n) if within_limiting_set?(set, shape)
			end
		end
		
		# Returns a struct
		# containing the found shape, normalized distance to collision, and collision normal
		# NOTE: Ignores sensor shapes
		
		# Must step over the segment query and short circuit it at the ruby-level
		# in order to make sure that the first collision which is allowable by the set
		# is cleared, and not some unusable point.
		def segment_query_first(start, stop, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil)
			old_segment_query do |shape, t, n|
				# (same test as above)
				if within_limiting_set?(set, shape)
					return CP::SegmentQueryInfo.new(shape, t, n)
				end
			end
		end
		
		# alternatively, could return the object, as well as a bunch of info about the collision
		segment_query_struct = Struct.new(:object, :collision_info)
		const_set "SegmentQueryInfo", segment_query_struct
		
		def segment_query_first(start, stop, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil)
			old_segment_query do |shape, t, n|
				# only care about set inclusion if set defined
				# (same test as above)
				if within_limiting_set?(set, shape)
					return SegmentQueryInfo.new(shape.obj, CP::SegmentQueryInfo.new(shape, t, n))
				end
			end
		end
		
		
		
		
		def bb_query(bb, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil, &block)
			# block params: |object_in_space|
			super(bb, layers, group) do |shape|
				block.call(shape.obj) if within_limiting_set?(set, shape)
			end
		end
		
		def shape_query(query_shape, set=nil, &block)
			# block params: |shape, contact_point_set|
			# actually, current Chipmunk 6 bindings do not seem to return the contact points
			super(query_shape) do |colliding_shape|
				block.call(colliding_shape) if within_limiting_set?(set, shape)
			end
		end
		
		
		
		
		
		
		
		
		# TODO: consider monkey patching this into Array
		def limit_selection(selection, limiting_set)
			if limiting_set == nil
				# no change
				
				return selection
			elsif limiting_set.empty?
				# no change
				
				return selection
			else
				# limit selection to just the items in the set
				# filter by the objects tied to the shapes,
				# not the actual shapes themselves
				
				return selection.select{ |obj| set.include? obj }
			end
		end
		private :limit_selection
		
		
		# See if the object bound to the given shape is in the limiting set.
		# Will return the proper truth value even when the Set is nil.
		# NOTE: Can not be patched into Set
		# FIXME: Known to cause problems with bb_query, may cause issues with other queries as well
		def within_limiting_set?(set, shape)
			# only care about set inclusion if set defined
			set != nil and set.include? shape.obj
		end
		private :within_limiting_set?
		
		

	
	# 	   _____           _       ___             __  _           
	# 	  / ___/___  _____(_)___ _/ (_)___  ____ _/ /_(_)___  ____ 
	# 	  \__ \/ _ \/ ___/ / __ `/ / /_  / / __ `/ __/ / __ \/ __ \
	# 	 ___/ /  __/ /  / / /_/ / / / / /_/ /_/ / /_/ / /_/ / / / /
	# 	/____/\___/_/  /_/\__,_/_/_/ /___/\__,_/\__/_/\____/_/ /_/ 
		class << self
			def load(filepath)
				# Create new space
				s = Space.new
				
				# Populate space with data from file
				raise "Could not find Space data at #{filepath}" unless File.exist? filepath
				
				# TODO: FINISH LOADING IMPLEMENTATION
				
				return s
			end
		end
		
		def dump(filepath)
			# TOOD: Rethinking dump implementation
			
			# File.open(filepath, "w") do |f|
			# 	f.puts YAML::dump(@objects)
			# end
		end
	end
end