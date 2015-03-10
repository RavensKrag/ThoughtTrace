module ThoughtTrace
	module Constraints


# stores raw constraint objects
class BackendCollection
	def pack
		data_dump = Hash.new
			@storage.each do |id, constraint|
				# id => [constraint class, {parameter map}]
				
				# convert class obj to string, convert hash wrapper data to regular hash
				data_dump[id] = [constraint.class.to_s, constraint.pack]
			end
		
		return data_dump
	end
	
	
	
	ENUM_CLASS = 0
	ENUM_PARAMETER_MAP = 1
	
	def unpack(data_dump)
		data_dump.each do |id, data|
			class_name = data[ENUM_CLASS]
			klass = Kernel.const_get class_name
			constraint = klass.unpack data[ENUM_PARAMETER_MAP]
			
			self[id] = constraint
			# may want to make this private or something?
			# don't want to confuse people about what interface to use.
			# you always want to add new objects with #add, but the hash-style interface is needed for serialization
		end
		
		return self
	end
end



end
end