module ThoughtTrace


# Not really a factory that produces exact copies of the registered objects,
# but rather one that generates SIMILAR objects
# (in the mathematical sense (ie equivalent, but not equal))
class CloneFactory
	def initialize
		@prototypes = Hash.new
	end
	
	# Store one instance as a prototype,
	# a basis from which other objects
	# of the same class can be created, via cloning
	def register_prototype(prototype)
		@prototypes[prototypes.class] = prototype
	end
	
	# Create a new object of the type specified by the given class
	def make(klass)
		prototype = @prototypes[klass]
		
		raise "No prototype registered for type #{klass}" if prototype.nil?
		
		clone = prototype.clone
		
		
		# special manipulations to "reset" certain classes
		# (clones should be "empty", but similar in style)
		# (thus, they are not REALLY clones, and have to be manipulated from the true clones)
		case clone.class
			when ThoughtTrace::Text
				# don't allow the text from the prototype to leak
				clone.string = ""
			else
		end
		
		return clone
	end
end



end