require 'securerandom'



module ThoughtTrace
	module Constraints


# NOTE: This was originally intended to be a rather abstracted collection, but currently only works with Constraint objects.
class ResourceCollection
	def initialize
		@storage = Hash.new
	end
	
	def add(constraint)
		id = SecureRandom.uuid
		# TOOD: maybe check collision just in case?
		
		@storage[id] = constraint
		
		return id
	end
	
	def [](id)
		return @storage[id]
	end
	
	def []=(id, constraint)
		@storage[id] = constraint
		return constraint
	end
	
	
	# NOTE: this could be a problem, because it exposes all of the stored elements to the outside world at will. That's not the intent, obviously, but it could still be a problem.
	def map_data_to_uuids
		@storage.invert
	end
	
	
	
	
	
	
	
	def pack
		data_dump = Hash.new
			@storage.each do |id, constraint|
				# id => [constraint class, {parameter map}]
				data_dump[id] = [constraint.class.to_s, constraint.closure.vars]
			end
		
		return data_dump
	end
	
	
	
	ENUM_CLASS = 0
	ENUM_PARAMETER_MAP = 1
	
	def unpack(data_dump)
		data_dump.each do |id, data|
			# may want to make this private or something?
			# don't want to confuse people about what interface to use.
			# you always want to add new objects with #add, but the hash-style interface is needed for serialization
			class_name = data[ENUM_CLASS]
			klass = Kernel.const_get class_name
			constraint = klass.new
			constraint.closure.load_data data[ENUM_PARAMETER_MAP]
			
			self[id] = constraint
		end
		
		return self
	end


end



end
end