# All pick callbacks return true IFF the pick has succeeded
# (currently, it's really just if, not IFF, because the main flow returns true)

# New return structure:
# returns true if pick successful
# returns false if hit the end
# returns nil if short circuits
	# ^ this is kinda iffy


module TextSpace
	module PickCallbacks
		class Selection
			def initialize(selection)
				@selection = selection
			end
			
			def pick(point)
				# pick from a group of objects
				
				# may just want to actually pass on the result of a query on an empty set (which would be nil)
				# oh, it actually does that, doesn't it
				return if @selection.empty?
				
				return SelectionQueries.point_query(@selection, point)
				# return @selection.point_query point
			end
		end
		
		class Space
			def initialize(space)
				@space = space
			end
			
			def pick(point)
				# pick one object out of the space
				# return SelectionQueries.point_query(@space, point)
				return @space.object_at(point)
			end
		end
		
		class Point
			def initialize(space, klass)
				@space = space
				@klass = klass
			end
			
			def pick(point)
				# project a point into the space, and create a new object there
				obj = @klass.new
				@space << obj
				obj.position = point
				return obj
			end
		end
	end
end