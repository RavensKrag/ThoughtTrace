module TextSpace
	# Queries
	# queries need to be defined to function upon any traversable collection
	# of items which could be contained within the Space
	# (should probably stick to traversals which are defined in Enumerable)
	# aka
	# (can safely assume that all traversals from Enumerable are implemented)
	
	# TODO: queries should be a part of all collections of objects, not stuck in a module like this. Refactor once Space is more like CP::Space (juggles information about the objects inside it that makes manual traversal of a whole data structure slow and cumbersome)
	module SelectionQueries
		class << self
			# Return objects whose bounding boxes overlap with the given bounding box
			def bb_query(collection, bb)
				collection.select do |obj|
					bb.intersect? obj.bb
				end
			end
			
			# Return the object at the given point
			# If there are multiple objects at the point requested, return only the best one
			def point_query(collection, position)
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
				
				
				selection = collection.select do |o|
					o.bb.contains_vect? position
				end
				
				selection.sort! do |a, b|
					a.bb.area <=> b.bb.area
				end
				
				# Get the smallest area values, within a certain threshold
				# Results in a certain margin of what size is acceptable,
				# relative to the smallest object
				selection = selection.select do |o|
					# TODO: Tweak margin
					size_margin = 1.8 # percentage
					
					first_area = selection.first.bb.area
					o.bb.area.between? first_area, first_area*(size_margin)
				end
				
				selection.sort! do |a, b|
					distance_to_a = a.bb.center.dist position
					distance_to_b = b.bb.center.dist position
					
					# Listed in order of precedence, but sort order needs to be reverse of that
					[a.bb.area, distance_to_a].reverse <=> [b.bb.area, distance_to_b].reverse
				end
				
				return selection.first
			end
			
			def empty_at?(collection, point)
				return collection.select{ |o| o.bb.contains_vect? point }.empty?
			end
		end
	end
end