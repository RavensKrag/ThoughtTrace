module ThoughtTrace
	module Style


class StyleObject
	def initialize
		@properties = Hash.new
	end
	
	def [](property)
		return @properties[property]
	end
	
	def []=(property, value) 
		@properties[property] = value
	end
	
	
	
	
	
	def pack
		hash = Hash.new
		@properties.collect do |property, value|
			hash[k] = pack_entry(value)
		end
		
		return hash
	end
	
	
	# pack objects which are "complex"
	# ie, they aren't part of the basic types YAML supports
	def pack_entry(value)
		if value.respond_to? :pack
			# pack up the special data as necessary
			# (should have the format "class<arg, arg, ..., arg>" when complete)
			data = data.pack
			data = data.join(', ') if data.is_a? Array
			
			return "#{value.class}<#{data}>"
		else
			# this data should just work. gonna just leave it alone
			return value
		end
	end
	private :pack_entry
	
	
	
	class << self
		def unpack(property_hash)
			obj = self.new
			
			
			property_hash.each do |property, value_data|
				value = 
					if value_data.is_a? String
						unpack_entry(value_data)
					else
						value
					end
				
				
				obj[property] = value
			end
			
			
			return obj
		end
		
		
		# string may be special data in the form of
		# "class<arg, arg, ..., arg>"
		# (in which case it needs to be unpacked into "real" data)
		# or it could just be a standard string
		def unpack_entry(string)
			exp = /(.*)\<(.*)\>/
			matchdata = string.match exp
			
			if matchdata
				# found specially encoded data
				klass = matchdata[1]
				args  = matchdata[2].strip!.split(/\s*,\s*/)
				
				return klass.unpack(*args)
			else
				# it's actually just a normal string
				return string
			end
		end
		private :unpack_entry
	end
	
	
	
end



end
end