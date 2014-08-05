require 'csv'
require 'fileutils'

module ThoughtTrace



class Space < CP::Space
	class List < Array
		# Convert entities back and forth between arrays of data using pack / unpack
		# and then save to disk using CSV ( can easily substitute for another format later )
		
		# This class handles extracting class names and saving them in the CSV
		# pack / unpack does not currently encode that data, and I don't think it should
		
		# Can accept optional arguments to pass through to pack / unpack
		
		def dump(path_to_folder, *args)
			# pack data
			packed_array =	self.collect do |object|
								next unless object.respond_to? :pack
								
								class_name = object.class.name.split('::').last # ignore modules
								[class_name] + object.pack(*args)
							end
			
			packed_array.compact! # necessary only because not all Entities are being processed
			
			
			# write to disk
			filename = self.class.const_get 'SERIALIZATION_FILENAME'
			path = File.join(path_to_folder, filename)
			full_path = File.expand_path path
			
			CSV.open(full_path, "wb") do |csv|
				packed_array.each do |data|
					csv << data
				end
			end
		end
		
		class << self
			def load(path_to_folder, space, *passthrough_args)
				list = self.new(space)
				
				
				
				# Populate that space with data from the disk
				filename = self.const_get 'SERIALIZATION_FILENAME'
				path = File.join(path_to_folder, filename)
				full_path = File.expand_path path
				
				
				
				# it's not actually an array of arrays, but CSV::Table has a similar interface
				arr_of_arrs = CSV.read(full_path,
								:headers => false, :header_converters => :symbol, :converters => :all
								)
				
				arr_of_arrs.each do |row|
					# split row into the first element, and then everything else
					klass_name, *args = row.to_a
					
					namespace = self.const_get 'CONST_SPACE'
					klass = namespace.const_get klass_name
					
					obj = klass.unpack(*passthrough_args,*args)
					
					list.add obj
				end
				
				
				
				return list
			end
		end
	end
	
	class EntityList < List
		# The creation of pack / unpack methods for Entity objects are semi-automated.
		# Details can be found in the serialization/ directory
		SERIALIZATION_FILENAME = "entities.csv"
		CONST_SPACE = ThoughtTrace
	end
	
	class QueryList < List
		SERIALIZATION_FILENAME = "queries.csv"
		CONST_SPACE = ThoughtTrace::Queries
	end
	
	class ConstraintList < List
		SERIALIZATION_FILENAME = "constraints.csv"
		CONST_SPACE = ThoughtTrace::Constraints
	end
	
	class GroupList < List
		SERIALIZATION_FILENAME = "groups.csv"
		CONST_SPACE = ThoughtTrace::Groups
	end
	
	
	
	
	# All objects in the space are saved to disk in a sort of project folder.
	# That folder will contain multiple files,
	# one for each type of data to be serialized.
	# Currently, the serialization format is CSV, but this can easily be switched out.
	
	# NOTE: Entity IDs are based on line INDEXES (zero-based)
	
	def dump(path_to_folder)
		# create data folder if it does not exist
		dirname = File.dirname(path_to_folder)
		FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
		
		@entities.dump path_to_folder
		
		
		entity_to_id_table = @entities.each_with_index.map{|x,i| [x,i]}.to_h
		
		@queries.dump path_to_folder, entity_to_id_table
		@constraints.dump path_to_folder, entity_to_id_table
		@groups.dump path_to_folder, entity_to_id_table
	end
	
	class << self
		def load(path_to_folder)
			# Create a new space
			space = ThoughtTrace::Space.new
			
			
			entities = ThoughtTrace::Space::EntityList.load path_to_folder, space
			
			
			
			id_to_entity_table = entities
			
			# have to pass space twice so that it ends up in #load as well as #unpack
			queries = ThoughtTrace::Space::QueryList.load(
								path_to_folder, space,    # load arguments
								id_to_entity_table, space # unpack arguments
						)
			constraints = ThoughtTrace::Space::ConstraintList.load(
								path_to_folder, space,    # load arguments
								id_to_entity_table, space # unpack arguments
						)
			
			groups = ThoughtTrace::Space::GroupList.load(
								path_to_folder, space,    # load arguments
								id_to_entity_table, space # unpack arguments
						)
			
			
			# can't think of a better way to set these variables
			# don't want them to normally be set through an outside API
			space.instance_variable_set :@entities, entities
			space.instance_variable_set :@queries, queries
			space.instance_variable_set :@constraints, constraints
			space.instance_variable_set :@groups, groups
			
			
			# Return the space with all the stuff in it
			return space
		end
	end
	
	
end


end