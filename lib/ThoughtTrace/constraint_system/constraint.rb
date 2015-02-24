# NOTE: keep graphical representations out of this class. That's a job for the Package, not the raw Constraint
module ThoughtTrace
	module Constraints


class Constraint
	attr_reader :closure
	
	def initialize(closure=nil)
		# lifetime of closure is not controlled by any one Constraint instance
		# although, one closure instance should be bound to a particular sort of Constraint
		# (or at least I think so)
		@closure = closure
		@closure ||= Closure.new
		
		# NOTE: need to figure out how you would share constraint objects between Constraints of the same type in this style
		
		
		# data for one particular pairing
		@a = nil
		@b = nil
		
		@cache = Hash.new
			# :prev => value from one tick ago
			# :next => value from this tick
		
		# NOTE: in optimized implementation, should figure out what data type is going to be stored in the cache at compile-time, and allocate enough space for it here. That way, the cache lookup is made faster due to data locality.
			# ie. allocate data on stack as value, rather than on heap + pointer
		# NOTE: if a bunch of these constraint wrappers are allocated in a pool, you could allocate space for the unknown @cache field to be equal to the largest possible cache. possible use of 'unions' (related to structs) if implementing in C.
			# ie) constraint, vis, e1, e2,  32 bytes
			#     constraint, vis, e1, e2,  12 bytes
			#     constraint, vis, e1, e2, 100 bytes

		
		
		
		
		
		# ---
		# what data needs to be reallocated if a Constraint is deleted and a new one made?
		# (it's really just "what needs to be reinitialized" (well, kinda))
			# I think it's just the cache?
			# everything else is just pointers
		#   ptr, ptr,     ptr, ptr, prev_data, this_data
		# retain this  |     reset this stuff
		
		# if you reinitialize one object, then any pointers to that thing will still work
		# if you delete and initialize a new one, then you could break pointers
	end
	
	def bind(a,b)
		# short circuit when pointers are the same as the existing ones
		return if @a.equal? a and @b.equal? b
		
		
		@a = a
		@b = b
		
		clear_cache
	end
	
	def unbind
		# TODO: implement this ASAP
		raise "NEED TO IMPLEMENT THIS"
	end
	
	
	
	

	def update(&block)
		return if @a.nil? or @b.nil? # short circuit if one or both targets are unbound
		# NOTE: @a and @b are currently both set at once. it's either going to be that both are bound, or both are unbound. As such, testing both of them seems a little odd.
		
		data = self.class.foo(@a,@b)
		# save the data from this tick so
		# 'call' has the proper data to work with
		# (also allows #bar? to use ':prev' to access old data from the previous frame, and the ':this', to access the data from this frame, which is exactly as expected.)
		save(data)
		
		if bar?
			call(@a,@b)
			
			
			# save the data from right now,
			# because we JUST CHANGED IT
			# 
			# of course the system thinks the data has been changed:
			# it has been, but it has been changed internally.
			# you only want the constraint to change if dependencies have been EXTERNALLY altered
			save(self.class.foo(@a,@b))
			
			
			
			block.call
		end
	end
	
	
	
	
	# check cache things
	# (this is the format of the data stored in @cache)
	def self.foo(a,b)
		# NOTE: for a low-level implementation, this should write to the memory location allocated by the cache, rather than allocating to some random place in the heap, and then returning a pointer. (note that 'direct return' would not be an option, because the data would be too large to fit in one register)
		[
			b[:physics].body.p
		]
	end
	
	# execute one tick
	def call(a,b)
		
	end
	
	
	
	
	
	
	
	
	# allow for generating copies of this Constraint
	# 
	# This is shaping up like the way Entities are created:
	# you save a reference copy, and then you make copies of it when you want new ones.
	# However, with Constraints, you need to be able to have both shared data, and copied data.
		# If you tried to port this style directly to lower-level code, it would mean that the closure would live in the reference constraint, and all other instances would point to that data?
		# NO
		# the data would always be heap allocated, as all Constraints would be the same
		# you wouldn't be able to have the reference type allocate obj, and then have the "copies" allocate *obj
		# that would require the reference and the copies to be separate types
		# and that would be very weird
	# Note that the Entity defines #dump and #load, and then uses that to implement #clone, but here we define copying first, and then implement serialization as a separate thing.
	# (this is due to the major issues behind trying to serialize a closure, which is mostly code)
	def deep_copy
		self.class.new(@closure.clone)
	end
	
	def linked_copy
		self.class.new(@closure)
	end
	
	
	
	
	
	
	
	
	
	
	
	# check if the cache is outdated
	def bar?
		# with new cache structure, data is written to cache every frame, so after a couple of frames of not firing, the two values in the cache will be the same.
		# Nothing wrong with that though. It's not like you're allocating any more data than before or anything.
		
		prev = @cache[:prev]
		this = @cache[:this]
		
		# if boolean, return that value instead, ignoring the cache
		return this if !!this == this
		
		
		# there is stored data but it's old, or no data has yet been stored
		prev && prev != this or prev.nil?
	end
	
	
	
	
	def clear_cache
		# NOTE: in a low-level implementation you just want to show that these memory regions are garbage. you don't want to free it, as you will soon need the space again, and you want to maintain data locality.
		# It might be best to have a one-byte flag to show if the region in in-use or garbage
		# (only need one BIT, but then there's data alignment to think about)
		@cache[:prev] = nil
		@cache[:this] = nil
	end
	
	
	private
	
	def save(data)
		# NOTE: in a low-level implementation of this, you want to have two "save slots", and juggle pointers to figure out what data is "this" and what is "prev", rather moving the data down one slot. (ie, you alternate saving data into the left slot, and the right slot, rather than always saving in the right slot)
		@cache[:prev] = @cache[:this]
		@cache[:this] = data
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	# this thing goes inside of a constraint, modifying particular values
	class Closure
		attr_reader :vars
		
		def initialize
			
		end
		
		def let(vars={}, &block)
			# merge data if data already exists
			# old data has precedence
			# (only use values from 'vars' if no other data has been set)
			vars = vars.merge @vars if @vars
			@vars = HashWrapper.new(vars)
			
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
		
		
		# load variable data from previous session
		def load_data(vars)
			@vars = HashWrapper.new(vars)
		end
		
		
		
		
		# custom hash class, for sensible error messages when trying to read undefined variables
		class HashWrapper < Hash
			def initialize(hash)
				hash.each{ |k,v| self[k] = v  }
			end
			
			def [](k)
				x = super(k)
				raise NameError, "no value defined for variable #{k.inspect}" if x.nil?
				
				return x
			end
		end
	end
end



end
end