require 'csv'
require 'fileutils'

module ThoughtTrace



class Space < CP::Space
	
	class EntityList < Array
		# Convert entities back and forth between arrays of data using pack / unpack
		# and then save to disk using CSV ( can easily substitute for another format later )
		
		# This class handles extracting class names and saving them in the CSV
		# pack / unpack does not currently encode that data, and I don't think it should
		
		# The creation of pack / unpack methods are semi-automated.
		# Details can be found in the serialization/ directory
		
		def dump(path_to_folder)
			# pack data
			packed_array =	self.collect do |entity|
								next unless entity.respond_to? :pack
								
								
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
			def load(space, path_to_folder)
				list = self.new(space)
				
				
				
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
					
					list.add obj
				end
				
				
				
				return list
			end
		end
	end
	
	class QueryList < Array
		def dump(path_to_folder)
			
		end
		
		class << self
			def load(space, path_to_folder)
				list = self.new(space)
				
				return list
			end
		end
	end
	
	class ConstraintList < Array
		def dump(path_to_folder)
			
		end
		
		class << self
			def load(space, path_to_folder)
				list = self.new(space)
				
				return list
			end
		end
	end
	
	
	
	# All objects in the space are saved to disk in a sort of project folder.
	# That folder will contain multiple files,
	# one for each type of data to be serialized.
	# Currently, the serialization format is CSV, but this can easily be switched out.
	def dump(path_to_folder)
		# create data folder if it does not exist
		dirname = File.dirname(path_to_folder)
		FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
		
		@entities.dump path_to_folder
		@queries.dump path_to_folder
		@components.dump path_to_folder
	end
	
	class << self
		def load(path_to_folder)
			# Create a new space
			space = ThoughtTrace::Space.new
			
			
			entities = ThoughtTrace::Space::EntityList.load space, path_to_folder
			queries = ThoughtTrace::Space::QueryList.load space, path_to_folder
			components = ThoughtTrace::Space::ConstraintList.load space, path_to_folder
			
			
			# can't think of a better way to set these variables
			# don't want them to normally be set through an outside API
			space.instance_variable_set :@entities, entities
			space.instance_variable_set :@queries, queries
			space.instance_variable_set :@components, components
			
			
			# Return the space with all the stuff in it
			return space
		end
	end
	
	
end


end