#    ____                  _          
#   / __ \__  _____  _____(_)__  _____
#  / / / / / / / _ \/ ___/ / _ \/ ___/
# / /_/ / /_/ /  __/ /  / /  __(__  ) 
# \___\_\__,_/\___/_/  /_/\___/____/  
# this file contains space queries only
# Main space implementation is in space.rb

# Most queries can take a set parameter, which limits the selection
# to some subset of the objects in the Space.
# Could be anything that implements #include? but Set is preferable for performance reasons.


module ThoughtTrace
	class Space
	
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
		def point_query(point, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, limit_to:nil, exclude:nil, &block)
			# block params: |object_in_space|
			
			selection = []
			@space.point_query(point, layers, group) do |shape|
				selection << shape.obj
			end
			
			selection.uniq!
			
			
			# select any and all groups where the query point lies inside the bounding shape
			# NOTE: these are Group objects, which are different from Chipmunk group tags
			groups = @groups.select{ |x| x[:physics].shape.point_query(point)  }
			selection += groups
			
			
			selection.select!{ |x| limit_to.include? x  }  if limit_to
			selection.reject!{ |x| exclude.include?  x  }  if exclude
			
			
			selection.each &block if block
			
			return selection
		end
		
		def point_query_first(point, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, limit_to:nil, exclude:nil)
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
		# (former body has been moved into #point_query_best_list)
		def point_query_best(point, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, limit_to:nil, exclude:nil)
			# TODO: Should short circuit when selection becomes empty
			# TODO: Short circuit on selection size of 1? (Only after initial bb query)
			
			# Select objects under the mouse
			# If there's a conflict, get smallest one (least area)
			
			# There should be some other rule about distance to center of object
				# triggers for many objects of similar size?
				
				# when objects are densely packed, it can be hard to select the right one
				# the intuitive approach is to try to select dense objects by their center
			
			
			# Initial query
			selection = self.point_query(point, layers, group, limit_to:limit_to, exclude:exclude)
			
			return nil if selection.empty?
			
			
			
			# get selection,
			# get entities living in the space
			# split entities into two categories:
				# standard entities
				# groups
			
			# sort selection and both entity groups in the same manner
			# join the three sorted lists, back to back
			
			# selection priority
			# selection > groups > standard entities
			
			# wait, maybe you don't need to have priority?
			# but do need to make sure that the selection makes it into the list for consideration
			# (it's not really stored in the space, so it wouldn't be in the standard point_query)
			
			# but wait,
			# currently the selection is stored in the InputManager
			# it's just a Group, but sitting in a special variable instead of in the Space.
			# Can't get to that variable from here.
			
			# Need to figure out if the selection is a group that's just marked so you can find it again, and then you easily delete it when the selection clears,
			# or if Groups are selections that have been made permanent.
			# (I think it would be better to automatically delete the old selections)
			
			
			# Sort by area
			selection.sort_by! do |x|
				x[:physics].shape.area
			end
			
			# Get the smallest area values, within a certain threshold
			# Results in a certain margin of what size is acceptable,
			# relative to the smallest object
				# NOTE: This is where the number of Entities being considered can drop.
			selection = selection.select do |o|
				# TODO: Tweak margin
				size_margin = 1.8 # percentage
				
				first_area = selection.first[:physics].shape.area
				o[:physics].shape.area.between? first_area, first_area*(size_margin)
			end
			
			selection.sort_by! do |x|
				# Assuming that the shapes all have their center on their local origin
				# TODO: need to update this to use proper #center calculations
				distance = x[:physics].body.pos.dist point
				
				# Listed in order of precedence, but sort order needs to be reverse of that
				[x[:physics].shape.area, distance].reverse
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
		
		
		
		# This iterates over all shapes, not all objects, as opposed to the point query.
		# This is to preserve the distances an normals of the collisions.
		# The objects can still be accessed through the shapes, so it's not a big deal.
			# Though, it may be what you want most often when you do this sort of thing,
			# so having to go through the shape may introduce unwanted noise to the code.
		def segment_query(start, stop, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, limit_to:nil, exclude:nil, &block)
			# block params: |shape, t, n|
			@space.segment_query(start, stop, layers, group) do |shape, t, n|
				block.call(shape, t, n) if within_limiting_set?(shape, limit_to, exclude)
			end
		end
		
		# Returns a struct
		# containing the found shape, normalized distance to collision, and collision normal
		# NOTE: Ignores sensor shapes
		
		# Must step over the segment query and short circuit it at the ruby-level
		# in order to make sure that the first collision which is allowable by the set
		# is cleared, and not some unusable point.
		def segment_query_first(start, stop, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, limit_to:nil, exclude:nil)
			@space.segment_query do |shape, t, n|
				# (same test as above)
				if within_limiting_set?(shape, limit_to, exclude)
					return CP::SegmentQueryInfo.new(shape, t, n)
				end
			end
		end
		
		# alternatively, could return the object, as well as a bunch of info about the collision
		segment_query_struct = Struct.new(:object, :collision_info)
		const_set "SegmentQueryInfo", segment_query_struct
		
		def segment_query_first(start, stop, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, limit_to:nil, exclude:nil)
			@space.segment_query do |shape, t, n|
				# only care about set inclusion if set defined
				# (same test as above)
				if within_limiting_set?(shape, limit_to, exclude)
					return SegmentQueryInfo.new(shape.obj, CP::SegmentQueryInfo.new(shape, t, n))
				end
			end
		end
		
		
		
		
		def bb_query(bb, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, limit_to:nil, exclude:nil, &block)
			# block params: |object_in_space|
			@space.bb_query(bb, layers, group) do |shape|
				block.call(shape.obj) if within_limiting_set?(shape, limit_to, exclude)
			end
		end
		
		def shape_query(query_shape, limit_to:nil, exclude:nil, &block)
			# block params: |shape, contact_point_set|
			# actually, current Chipmunk 6 bindings do not seem to return the contact points
			@space.shape_query(query_shape) do |colliding_shape|
				block.call(colliding_shape) if within_limiting_set?(shape, limit_to, exclude)
			end
		end
		
		
		
		
		
		
		
		# See if the object bound to the given shape is in the limiting set.
		# Will return the proper truth value even when the Set is nil.
		# NOTE: Can not be patched into Set
		# FIXME: Known to cause problems with bb_query, may cause issues with other queries as well
			# NOTE: that bug notice applied to the old version of this method. I'm not sure about these things now.
			# TODO: check over query methods to make sure they all work as expected.
		def within_limiting_set?(shape, limit_to, exclude)
			# only care about set inclusion if set defined
			
			# inside the set of things that must be present,
			# and not any of the things that are explicitly banned
			# if limit_to.include? shape and !exclude.include? shape
			return false   unless limit_to.include? shape    if limit_to
			return false   unless !exclude.include? shape    if exclude
			
			
			
			# if you get this far... 
			return true
		end
		private :within_limiting_set?
		
		

	end
end