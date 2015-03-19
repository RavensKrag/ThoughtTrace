module ThoughtTrace

class Space


module Packageable # mixin
	# contract: must define the following - 
		# collect
		# empty?
		# add
	# in order for #pack and #unpack to function
	
	
	# return a data blob
	def pack
		return self.collect{ |e| pack_with_class_name(e)  }
	end
	
	# take a data blob, and load that data into this object
	# NOTE: this method basically assumes that the current collection is empty. if it's not, weird things can happen
	def unpack(data)
		unless self.empty?
			identifier = "#<#{self.class}:#{object_space_id_string}"
			
			warn "#{identifier}#unpack_into_self may not function as intended because this object is not empty." 
		end
		
		data.each do |row|
			obj = unpack_with_class_name(row)
			self.add(obj)
		end
	end
	
	private
	
	def pack_with_class_name(obj)
		if obj.respond_to? :pack
			return obj.pack.unshift(obj.class.name)
			# [class_name, arg1, arg2, arg3, ..., argn]
		else
			return nil
		end
	end
	
	def unpack_with_class_name(array)
		# array format: same as the output to #pack_with_class_name
		klass_name = array.shift
		args = array
		
		klass = Kernel.const_get klass_name
		
		return klass.unpack *args
	end
end



end
end