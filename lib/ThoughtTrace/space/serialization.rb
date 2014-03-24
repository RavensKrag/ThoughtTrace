require 'csv'

module ThoughtTrace
	class Space < CP::Space
		# should ideally be able to specify format,
		# and then the system can load / save the necessary data in accordance with the schema
		
		# FORMATTING = {
		# 	# mapping of numbers to font names
		# 	:font => %w[number name],
		# 	:font => [
		# 		['number', 'L'], # 32-bit unsigned
		# 		['name', '']
		# 	]
			
		# 	# must jump through font association table to resolve font
		# 	:text => %w[font.number x y height text]
			
			
		# 	:text => %w[font.number components-physics-body-x components-physics-body-y components-style-height text]
		# }	
		
		# filepath points to the directory containing the necessary project files
		
		# consider using Array#pack and String#unpack instead of CSV
		
		
		
		
		
		
		# # to serialize string using pack use
		# # dump
		# 	[str].pack "Z#{str.length+1}" # always end strings with a null terminator
		# # load
		# 	blob_string.unpack 'Z*' # unpack a null-terminated string
		
		
		
		
		
		
		def dump(filepath)
			packed_array =	@objects.collect do |entity|
								# currently only have builds for Text
								next unless entity.is_a? ThoughtTrace::Text
								
								
								class_name = entity.class.name.split('::').last # ignore modules
								[class_name] + entity.pack
							end
			
			packed_array.compact! # necessary only because not all Entities are being processed
			
			CSV.open(filepath, "wb") do |csv|
				packed_array.each do |data|
					csv << data
				end
			end
		end
		
	class << self
		def load(filepath)
			# Create a new space
			space = ThoughtTrace::Space.new
			
			# Populate that space with data from the disk
			path = File.join(filepath, 'text.csv')
			full_path = File.expand_path path
			
			
			
			# it's not actually an array of arrays, but CSV::Table has a similar interface
			arr_of_arrs = CSV.read(full_path,
							:headers => false, :header_converters => :symbol, :converters => :all
							)
			
			arr_of_arrs.each do |row|
				args = row.to_a
				
				klass_name = args.shift
				
				klass = ThoughtTrace.const_get klass_name
				
				obj = klass.unpack(*args)
				
				space.add obj
			end
			
			
			# Return the space with all the stuff in it
			return space
		end
	end


	end
end