module ThoughtTrace
	module Constraints



class Collection
	# convert this collection to and from a nested array structure
	# this serialization process does not actually interface with the disk at all
	
	
	def pack(data_dump)
		
	end
	
	
	def self.unpack(data_dump)
		collection = self.new
		
		
		data_dump.each do |constraint_data|
		# constraint_data
				# [constraint, enumerator, visualization, entity_list]
			
			a = [
				ThoughtTrace::Constraints,
				ThoughtTrace::Constraints::Enumerators,
				ThoughtTrace::Constraints::Visualizations
			]

			b = constraint_data.first(3)

			c = 
				a.zip(b).collect do |container, const_name|
					klass = container.const_get const_name
				end
			
			
			
			entity_list = constraint_data.last
			
			
			
			collection.add *c, entity_list
		end
		
		return collection
	end	
end


end
end