module ThoughtTrace
	module Constraints


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
			# TODO: don't pass @vars if no custom variables have been declared. ie, if empty hash
			
			out = 
				if @vars.empty?
					@block.call *args
				else
					@block.call @vars, *args
				end
			return out
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