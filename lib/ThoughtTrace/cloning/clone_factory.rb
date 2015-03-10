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
	# NOTE: this code is SLIGHTLY different that the code from Space::List, because it assumes the location of the classes of prototype objects. This is because all prototypes are serializations of core entity classes, and will never be more complex types, such as prefabs.
	# This allows for less data stored on disk, which makes reading the prototypes.csv file by hand much easier. Much less noise.
	# It may be preferable to make the code more maintainable, rather than making the data readable, as the system reaches finalization. However, it makes it easier to debug in these early-days.
	def pack
		@prototypes.values.collect do |object|
			next unless object.respond_to? :pack
			
			class_name = object.class.name.split('::').last # ignore modules
			[class_name] + object.pack
		end
	end
	
	def unpack(data)
		list = 
			data.collect do |row|
				# split row into the first element, and then everything else
				klass_name, *args = row.to_a
				
				
				klass = ThoughtTrace.const_get klass_name
				
				obj = klass.unpack(*args)
				
				
				# pseudo-return
				obj
			end
		
		
		list.each do |prototype|
			self.register_prototype prototype
		end
		
		return self
	end
end



end