module ThoughtTrace
	module Constraints



class Collection
	def initialize
		@list = Array.new
	end
	
	
	# currently assuming constraints are method objects
	# yes. method. objects.
	# take the containing object and call #method(name) to retrieve the method object
	def add(package)
		# package could be a ConstraintPackage, or it could just be a raw Constraint
		# (the latter case is an optimization, not a "normal" thing)
		@list << package
	end
	
	def update
		@list.each do |package|
			package.update
		end
	end
	
	def draw
		@list.each do |package|
			# raw Constraint objects don't have visualizations, so not all objects will #draw
			package.draw if package.respond_to? :draw
		end
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	# convert this collection to and from a nested array structure
	# this serialization process does not actually interface with the disk at all
	
	
	def pack
		
	end
	
	
	def self.unpack(data_dump)
		collection = self.new
		
		
		
		
		return collection
	end
end


end
end