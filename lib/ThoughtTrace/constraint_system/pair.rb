module ThoughtTrace
	module Constraints


class Pair
	attr_reader :a, :b, :constraint
	
	def initialize(constraint)
		@a = nil
		@b = nil
		
		@cache = Cache.new
		@constraint = constraint
	end
	
	
	def bind(a,b)
		# short circuit when pointers are the same as the existing ones
		return if @a.equal? a and @b.equal? b
		
		@a = a
		@b = b
		
		@cache.clear
	end
	
	def unbind
		# TODO: implement this ASAP
		# raise "NEED TO IMPLEMENT THIS"
		@a = nil
		@b = nil
		
		@cache.clear
		#NOTE: don't really need to clear now, technically
		# already clearing on bind, don't really need to do both.
	end
	
	def update(&block)
		return if @a.nil? or @b.nil? # short circuit if one or both targets are unbound
		# NOTE: @a and @b are currently both set at once. it's either going to be that both are bound, or both are unbound. As such, testing both of them seems a little odd.
		
		
		# save the data from this tick so
		# 'call' has the proper data to work with
		# (also allows #bar? to use ':prev' to access old data from the previous frame, and the ':this', to access the data from this frame, which is exactly as expected.)
		@cache.save(@constraint.foo(@a,@b))
		
		if @cache.bar?
			@constraint.call(@a,@b,@cache)
			
			
			# save the data from right now,
			# because we JUST CHANGED IT
			# 
			# of course the system thinks the data has been changed:
			# it has been, but it has been changed internally.
			# you only want the constraint to change if dependencies have been EXTERNALLY altered
			@cache.save(@constraint.foo(@a,@b))
			
			block.call if block
		end
	end
end



end
end