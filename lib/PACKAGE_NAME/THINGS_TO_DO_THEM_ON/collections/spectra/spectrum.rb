# Allow for attachment of entities along a normalized axis
# This normalized axis can be interpreted in a variety of ways, based on context.
# 
# It is not up to this class to specify how this
# normalized continuum should be used, or visualized,
# but merely to provide such a structure.


# NOTE: Not sure if this next note is relevant or not any more. Should think about it more.
# Should be able to assign multiple entities to the same value. ie, keys are not unique
# --> this property is currently not satisfied
# actually, this is probably a horrible idea,
# because if you have two identical properties in a TextSpace at the same point on a Spectrum,
# you will not be able to reasonably select one over the other
# (but current systems should not select two when they should one, which is good)
class Spectrum
	def initialize
		# format of @children (associative array)
		# [
		# 	[key, value],
		# 	[key, value],
		# 	[key, value]
		# ]
		
		@children = Array.new # sorted associative array
	end
	
	# set value
	def []=(key,value)
		unless key.is_a? Float and key.between? 0.0, 1.0
			raise "Key must be a normalized float (number between 0.0 and 1.0)"
		end
		
		# make sure the list stays sorted
		@children.push [key, value]
		@children.sort_by!{|key, value| key}
		
		return value # for consistency with Hash#[]=
	end
	
	# access value
	def [](key)
		unless key.is_a? Float and key.between? 0.0, 1.0
			raise "Key must be a normalized float (number between 0.0 and 1.0)"
		end
		
		# TODO: use #bsearch instead of #find, (binary search over linear scan)
		# NOTE: #bsearch is new to Ruby 2.0
		return @children.find{ |stored_key, stored_value| key == stored_key }.last
	end
	
	# remove value
	def delete(key)
		unless key.is_a? Float and key.between? 0.0, 1.0
			raise "Key must be a normalized float (number between 0.0 and 1.0)"
		end
		
		
		out = nil
		@children.delete_if do |stored_key, stored_value|
			if key == stored_key
				out = stored_value
				
				true
			end
		end
		
		return out # return stored value for deleted key, for consistency with Hash#delete
	end
	
	
	# TODO: Allow traversing of children in order of their position on the continuum
	def each(&block)
		@children.each &block
	end
	
	# Traverse children within a certain section of the continuum
	def each_in_range(range, &block)
		@children.each do |normalized_position, child|
			block.call normalized_position, child if range.include? normalized_position
		end
	end
end