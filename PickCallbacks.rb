# All pick callbacks should return nil if no valid object can be picked.

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
				# only create objects in empty space
				
				return nil unless @space.empty_at? point
				
				
				obj = @klass.new
				@space << obj
				obj.position = point
				return obj
			end
		end
	end
end