class Constraint
	# accept parameters that can be used to alter the #call step
	def initialize
		
	end

	# list the things that will be changed
	# needed to figure out when the entities are changing

	# dependency, prerequisite?
	# (is it a concurrent dependency? - interrelated, correlated)
	def foo(a,b)
		[
			a[:physics].height
		]
	end

	# execute one tick
	def call(a,b)
		
	end
	
	# allow for Proc-style square-bracket calling shorthand
	alias :[], :call
	
	
	
	
	# this thing goes inside of a constraint, modifying particular values
	class Closure
		attr_reader :vars
		
		def initialize
			
		end
		
		def let(vars={}, &block)
			@vars = vars
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
	end
end
