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
								
								entity.class.pack entity
							end
			
			packed_array.compact! # necessary only because not all Entities are being processed
			
			CSV.open(filepath, "wb") do |csv|
				header = "font name,x,y,height,string".split(',')
				
				
				csv << header
				
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
			
			File.open(full_path, 'r') do |f|
				csv = CSV.new(f,
						:headers => true, :header_converters => :symbol, :converters => :all
					)
				
				rows_as_hashes = csv.to_a.map {|row| row.to_hash }
				
				rows_as_hashes.each do |row|
					font = ThoughtTrace::Font.new row[:font_name]
					
					text = ThoughtTrace::Text.new font
					text.string = row[:string]
					
					text[:physics].body.p = CP::Vec2.new(row[:x], row[:y])
					
					text[:style][:height] = row[:height]
					text.resize!
					
					space.add text
				end
			end
			
			# Return the space with all the stuff in it
			return space
		end
	end


	end
end