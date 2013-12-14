# All pick callbacks should return nil if no valid object can be picked.

# Although the return value of Action#pick can not be used to alter Action state flow,
# (as #pick is called by external stuff)
# these method can use their return value to signal that flow should be altered.

module TextSpace
	module PickCallbacks
		class Selection
			def initialize(space, selection)
				@space = space
				@selection = selection
			end
			
			def pick(point)
				# pick from a group of objects
				
				return @space.point_query_best(point, CP::ALL_LAYERS, CP::NO_GROUP, @selection)
			end
		end
		
		class Space
			def initialize(space)
				@space = space
			end
			
			def pick(point)
				# pick one object out of the space
				return @space.point_query_best(point)
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
				@space.add obj
				obj.position = point
				return obj
			end
		end
	end
end