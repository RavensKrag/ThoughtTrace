require 'csv'


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
	
	def has_property?(property)
		@property.has_key? property
	end
	
	
	def ==(other)
		return @properties.all?{ |k,v|  v == other[k] }
	end
	
	
	
	
	
	def pack
		hash = Hash.new
		@properties.each do |property, value|
			hash[property] = pack_entry(value)
		end
		
		return hash
	end
	
	
	# pack objects which are "complex"
	# ie, they aren't part of the basic types YAML supports
	def pack_entry(value)
		if value.respond_to? :pack and not value.is_a? Array
			# NOTE: recall that all Array objects respond to #pack, that's where I got the name from. But that's not actually the interface that you're checking for...
			
			
			# pack up the special data as necessary
			# (should have the format "class<arg, arg, ..., arg>" when complete)
			data = value.pack
			
			
			csv_string = 
				CSV.generate do |csv|
					csv << [data]
				end

			csv_string.chomp!
			
			
			return "#{value.class}<#{csv_string}>"
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
						value_data
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
				klass       = matchdata[1]
				csv_string  = matchdata[2]
				
				
				# parse strings into actual data
				klass = Kernel.const_get klass
				
				
				args = CSV.parse(
							csv_string,
							:headers => false, :header_converters => :symbol, :converters => :all
						).first # [[arg, arg, ..., arg]] is the raw CSV conversion
				
				
				
				# NOTE: Be very careful, as String#unpack is a method that does exist. It is the official counterpart to Array#pack
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