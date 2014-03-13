require 'csv'

module TextSpace
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
			@objects.each do |entity|
				if entity.is_a? TextSpace::Text
					
					font = entity.font
					pos = entity[:physics].body.p # CP::Vec2
					height = entity[:style][:height] # Float
					string = entity.string
					
					data = [font, pos, height, string]
					
					blob = data.pack '' # need to figure out formatting string
					
					
					# nuke file from last save, and put all the known objects into it
					# (note, current position of loop makes this code not follow logic)
					# NOTE: can optimize by only editing the effected objects
						# would require objects to have a unique ID that persists between sessions
						# could translate between line number and that unique ID
					File.open(File.join(filepath, 'text',), 'w') do |f|
						f.puts blob
					end
				end
			end
			
			
			
			
			
			File.open(File.join(filepath, 'font'), 'w') do |f|
				f.puts
			end
		end
		
	class << self
		def load(filepath)
			# Create a new space
			space = TextSpace::Space.new
			
			# Populate that space with data from the disk
			path = File.join(filepath, 'text.csv')
			full_path = File.expand_path path
			
			puts full_path
			
			File.open(full_path, 'r') do |f|
				csv = CSV.new(f,
						:headers => true, :header_converters => :symbol, :converters => :all
					)
				
				rows_as_hashes = csv.to_a.map {|row| row.to_hash }
				
				rows_as_hashes.each do |row|
					font = TextSpace::Font.new row[:font]
					
					text = TextSpace::Text.new font
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