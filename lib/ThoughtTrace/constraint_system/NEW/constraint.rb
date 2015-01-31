class Constraint
	attr_reader :closure
	
	# accept parameters that can be used to alter the #call step
	def initialize
		@closure = Closure.new
	end
	
	# list the things that will be changed
	# needed to figure out when the entities are changing

	# dependency, prerequisite?
	# (is it a concurrent dependency? - interrelated, correlated)
	def foo(a,b)
		[
			# this is only an example. really, for master class, this should be blank
			a[:physics].height
		]
	end

	# execute one tick
	def call(a,b)
		
	end
	
	# allow for Proc-style square-bracket calling shorthand
	alias :[] :call
	
	
	
	
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
