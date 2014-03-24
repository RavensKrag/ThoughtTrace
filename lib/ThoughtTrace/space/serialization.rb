require 'csv'
require 'fileutils'

module ThoughtTrace
	class Space < CP::Space
		# Convert entities back and forth between arrays of data using pack / unpack
		# and then save to disk using CSV ( can easily substitute for another format later )
		
		# This class handles extracting class names and saving them in the CSV
		# pack / unpack does not currently encode that data, and I don't think it should
		
		# The creation of pack / unpack methods are semi-automated.
		# Details can be found in the serialization/ directory
		
		def dump(path_to_folder)
			# create data folder if it does not exist
			dirname = File.dirname(path_to_folder)
			FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

			
			# pack data
			packed_array =	@objects.collect do |entity|
								# currently only have builds for Text
								next unless entity.is_a? ThoughtTrace::Text
								
								
								class_name = entity.class.name.split('::').last # ignore modules
								[class_name] + entity.pack
							end
			
			packed_array.compact! # necessary only because not all Entities are being processed
			
			
			# write to disk
			path = File.join(path_to_folder, 'entities.csv')
			full_path = File.expand_path path
			
			CSV.open(full_path, "wb") do |csv|
				packed_array.each do |data|
					csv << data
				end
			end
		end
		
	class << self
		def load(path_to_folder)
			# Create a new space
			space = ThoughtTrace::Space.new
			
			# Populate that space with data from the disk
			path = File.join(path_to_folder, 'entities.csv')
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