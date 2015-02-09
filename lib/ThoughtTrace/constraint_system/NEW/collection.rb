module ThoughtTrace
	module Constraints



class Collection
	def initialize
		@list = Array.new
	end
	
	
	# currently assuming constraints are method objects
	# yes. method. objects.
	# take the containing object and call #method(name) to retrieve the method object
	def add(constraint, visualization)
		@list << ConstraintPackage.new(constraint, visualization)
	end
	
	def update
		@list.each do |package|
			package.update
		end
	end
	
	def draw
		@list.each do |package|
			package.draw
		end
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	# convert this collection to and from a nested array structure
	# this serialization process does not actually interface with the disk at all
	
	
	def pack
		
	end
	
	
	def self.unpack(data_dump)
		collection = self.new
		
		
		data_dump.each do |constraint_data|
			# constraint_data
			constraint, visualization, a,b = constraint_data
			
			
			
			a = [
				ThoughtTrace::Constraints,
				ThoughtTrace::Constraints::Visualizations
			]
			
			b = [constraint, visualization]
			
			c = 
				a.zip(b).collect do |container, const_name|
					klass = container.const_get const_name
				end
			
			
			# THIS IS WEIRD
			# DON'T ACTUALLY DO THIS
			# don't do this in deployment code
			
			# I didn't want the initialization to happen here,
			# I wanted instances of classes to be loaded into the Collection
			# so like... the data that is serialized I guess should be instances?
			# c[0] = c[0].new
			
			
			
			
			d = [:constraint, :enumerator, :visualization].zip(c).to_h
			
			constraint    = d[:constraint].new # DON'T ACTUALLY DO THIS IN PRODUCTION CODE
			enumerator    = d[:enumerator].new(entity_list)
			visualization = d[:visualization].new
			
			
			collection.add constraint, enumerator, visualization
		end
		
		return collection
	end
end


end
end