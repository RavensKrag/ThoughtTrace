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
		@prototypes[prototype.class] = prototype
	end
	
	# Create a new object of the type specified by the given class
	def make(klass)
		prototype = @prototypes[klass]
		
		raise "No prototype registered for type #{klass}" if prototype.nil?
		
		clone = prototype.clone
		
		
		# special manipulations to "reset" certain classes
		# (clones should be "empty", but similar in style)
		# (thus, they are not REALLY clones, and have to be manipulated from the true clones)
		if clone.is_a? ThoughtTrace::Text
			# don't allow the text from the prototype to leak
			clone.string = ""
		end
		
		
		# Make sure that position is always reset. Want prototypes to spawn in a reliable way.
		if clone[:physics]
			clone[:physics].body.p = CP::Vec2.new(0,0)
		end
		
		
		return clone
	end
	
	
	
	
	
	
	# NOTE: The clone factory reads the same files as are generated by the Space for storing Entities. (The space generates additional files for constraints, etc)
	def pack
		@prototypes.values.collect do |object|
			next unless object.respond_to? :pack
			
			class_name = object.class.name.split('::').last # ignore modules
			[class_name] + object.pack
		end
	end
	
	class << self
		def load(filepath)
			factory = self.new
			
			
			full_path = File.expand_path filepath
			
			# it's not actually an array of arrays, but CSV::Table has a similar interface
			arr_of_arrs = CSV.read(full_path,
							:headers => false, :header_converters => :symbol, :converters => :all
							)
			
			list = 
				arr_of_arrs.collect do |row|
					# split row into the first element, and then everything else
					klass_name, *args = row.to_a
					
					
					klass = ThoughtTrace.const_get klass_name
					
					obj = klass.unpack(*args)
					
					
					# pseudo-return
					obj
				end
			
			
			list.each do |prototype|
				factory.register_prototype prototype
			end
			
			return factory
		end
	end
end



end