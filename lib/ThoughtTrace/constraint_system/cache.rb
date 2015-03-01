module ThoughtTrace
	module Constraints


class Cache
	def initialize
		@prev = nil # value from one tick ago
		@this = nil # value from this tick
		
		# NOTE: in optimized implementation, should figure out what data type is going to be stored in the cache at compile-time, and allocate enough space for it here. That way, the cache lookup is made faster due to data locality.
			# ie. allocate data on stack as value, rather than on heap + pointer
		# NOTE: if a bunch of Pairs are allocated in a pool, you could allocate space for the unknown @cache field to be equal to the largest possible cache. possible use of 'unions' (related to structs) if implementing in C.
			# ie) constraint, e1, e2,  32 bytes
			#     constraint, e1, e2,  12 bytes
			#     constraint, e1, e2, 100 bytes
	end
	
	
	# test if the two values match or not
	def bar?
		# with new cache structure, data is written to cache every frame, so after a couple of frames of not firing, the two values in the cache will be the same.
		# Nothing wrong with that though. It's not like you're allocating any more data than before or anything.
		
		# if boolean, return that value instead, ignoring the cache
		return @this if !!@this == @this
		
		
		# there is stored data but it's old, or no data has yet been stored
		@prev && @prev != @this or @prev.nil?
	end
	
	# save a new value in the cache, kicking out the oldest value
	def save(data)
		# NOTE: in a low-level implementation of this, you want to have two "save slots", and juggle pointers to figure out what data is "this" and what is "prev", rather moving the data down one slot. (ie, you alternate saving data into the left slot, and the right slot, rather than always saving in the right slot)
		@prev = @this
		@this = data
	end
	
	# clear the cache
	def clear
		# NOTE: in a low-level implementation you just want to show that these memory regions are garbage. you don't want to free it, as you will soon need the space again, and you want to maintain data locality.
		# It might be best to have a one-byte flag to show if the region in in-use or garbage
		# (only need one BIT, but then there's data alignment to think about)
		@prev = nil
		@this = nil
	end
end



end
end