module ThoughtTrace


class CloneFactory
	def initialize
		@prototypes = Hash.new
	end
	
	# Store prototype of a particular class for later cloning
	def register_prototype(prototype)
		@prototypes[prototypes.class] = prototype
	end
	
	# Generate new clone based on the given class
	def make(klass)
		@prototypes[klass].clone
		# TODO: update #clone methods for all Entity objects
	end
end



end