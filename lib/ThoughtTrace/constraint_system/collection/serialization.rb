module ThoughtTrace
	module Constraints



class Collection
	# convert this collection to and from a nested array structure
	# this serialization process does not actually interface with the disk at all
	
	
	def pack
		
	end
	
	
	def self.unpack(data_dump)
		collection = self.new
		
		
		data_dump.each do |constraint_data|
			# constraint_data
					# [constraint, enumerator, visualization, *entity_list]
			constraint, enumerator, visualization, *entity_list = constraint_data
			
			
			
			a = [
				ThoughtTrace::Constraints,
				ThoughtTrace::Constraints::Enumerators,
				ThoughtTrace::Constraints::Visualizations
			]
			
			b = [constraint, enumerator, visualization]
			
			c = 
				a.zip(b).collect do |container, const_name|
					klass = container.const_get const_name
				end
			
			
			
			
			
			
			
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