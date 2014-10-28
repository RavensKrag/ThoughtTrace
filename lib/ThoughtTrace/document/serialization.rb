require 'fileutils'

require 'csv'
require 'yaml'

module ThoughtTrace



class Document
	# do a list of things,
	# specific implementations for actions can be answered by particular collections
	# (builder pattern)
	
	def dump(path_to_folder)
		entities              = @space.entities
		
		groups                = @space.groups
		constraints           = @space.constraints
		
		styled_entities       = @space.entities.select{ |e|  e[:style] }.compact
		query_marked_entities = @space.entities.select{ |e|  e[:query] }.compact
		# NOTE: compact removes nil entries
		
		
		
		# these objects can just be saved
		# need to get IDs for them so I can reference these records from the other documents
		@prototypes
		@prefabs
		@named_styles
		
		# TODO: serialize the 'abstract types': prototypes, prefabs, and loose styles
		# NOTE: @named_styles collection has already been serialized as part of the component system, in order to make sure that Style data is always linked correctly
		# NOTE: entries in the Entity list may be of a basic entity type, or they may be of a prefab type. Not sure how that will effect the current systems.
		
		
		
		
		@project_directory = File.expand_path path_to_folder
		# pack entities
		
		# pack all other data
		# use conversion table to replace entity entries with IDs in all but main entity blob
		
		# write entities to disk
		# write all other data to disk
		
		
		# TODO: consider renaming variables with 'dump' in the name
		# NOTE: This segment of the code uses 'dump' in variable names to refer to 'lists of packed objects'. This can be confusing, as 'dump' generally means "write to file on disk" and 'pack' generally means "take the data from this object, and put it into an array"
		
		
		
		
		# move into project directory
		# (create directory if necessary)
		Dir.mkdir @project_directory unless File.directory?(@project_directory)
		
		Dir.chdir @project_directory do
			entity_dump = entities.collect{ |e| pack_with_class_name(e)  }
			write_data(entity_dump, "entities")
			
			
			entity_to_id_table = entities.each_with_index.to_h
			
			
			
			
			
			
			
			# TODO: rename function
			# TODO: move to method, or consider using closure properties to obtain entity list
			# (it is kind nice for readability to have it inline like this, but having full abstraction would also be good)
			foo = ->(component_name){
				block = Proc.new{ |e| e[component_name]   }
				
				
				entity_partition = entities.select(&block).compact # selection
				relevant_components = entity_partition.collect(&block) # extraction
				
				
				
				entity_ids = entity_partition.collect{ |e| entity_to_id_table[e]  }
				join = entity_ids.zip(relevant_components).to_h
				
				return join
			}
			
			
			
			
			# TODO: do not specify file extension in write function call
			# TODO: change name to abstract the name of format being used
			# (note that CSV is being used for 'lists of lists' and YAML is pretty much just an object dump)
			
			
			join = foo[:style]
			
			style_data = {
				:named_styles => @named_styles,
				:components => join
			}
			
			
			join = foo[:query]
			
			query_data = {
				:components => join
			}
			
			
			
			component_data = {
				:style => style_data,
				:query => query_data
			}
			write_yaml_file(component_data, 'components')
			
			
			
			
			
			
			
			
			
			
			
			{
				'groups'      => groups,
				'constraints' => constraints
			}.each do |type, list|
				# pack
				packed_array = list.collect{ |obj| pack_with_class_name(obj)  }.compact
				
				# replace entities with IDs (non-Entity entries should remain unmodified)
				packed_array.each{ |data| data.map! &replace_according_to(entity_to_id_table)  }
				# (consider if using an actual database backend will get rid of needing to do this sort of thing)
				# (in that case, you would probably retain the IDs on the objects, so you wouldn't have THIS problem
				# (but you may have a similar issue with converting from objects -> records)
				
				write_data(packed_array, type)
			end
		end
	end
	
	
	def self.load(path_to_folder)
		project_directory = path_to_folder
		
		# === create new document
		document = self.new
		
		
		# === load data from disk
		entity_dump = read_data(project_directory, "entities")
		entities =	entity_dump.each.collect do |row|
						data = row.to_a
						
						klass_name = data.shift
						args = data
						
						klass = ThoughtTrace.const_get(klass_name)
						klass.unpack(*args)
					end
		
		id_to_entity_table = entities.each_with_index.to_h.invert
		
		
		
		
		
		
		
		
		# --- components
		# load component data from disk
		# separate hashes out into relevant parts as necessary
		# copy component data back onto the corresponding entities (use the id -> entity table)
		# (no need to store component data anywhere other than on the entities)
		
		# NOTE: this currently won't exactly work, because the 'Shared Query Style' is currently being saved in both the Style dump and the Query dump. So, that needs to be resolved, otherwise this will get really weird.
		data = load_yaml_file(project_directory, 'components')
		
		style_data = data[:style]
		query_data = data[:query]
		
		named_styles    = style_data[:named_styles]
		
		[style_data, query_data].collect{ |x| x[:components]  }.each do |component_list|
			component_list.each do |entity_id, component|
				entity = id_to_entity_table[entity_id]
				
				interface = component.class.interface
				
				existing_component = entity[interface]
				if existing_component
					existing_component.mirror component
				else
					entity.add_component component
				end
			end
		end
		
		
		
		
		
		
		
		
		
		# other stuff that uses entities
		types = ['groups', 'constraints']
		out = 
			types.collect do |type|
				data_dump = read_data(project_directory, type)
				
				data_dump.each{ |data| data.map! &replace_according_to(id_to_entity_table)  }
				
				data_dump.collect{ |data| unpack_with_class_name(data)  }
			end
		other_stuff = types.zip(out).to_h
		
		
		
		
		# abstract types
			path = File.join path_to_folder, 'prototypes.csv'
		prototypes = ThoughtTrace::CloneFactory.load path
		# ----
		
		
		
		# === populate the space
		{
			:entities    => entities,
			:groups      => other_stuff['groups'],
			:constraints => other_stuff['constraints']
		}.each do |name, collection|
			collection.each{ |obj| document.space.send(name).add obj  } 
		end
		
		# === set abstract data types
		document.instance_eval do
			# TODO: make sure that this value does not get set to nil when no data is loaded. or crashes. or anything bad like that
			@named_styles = named_styles
			@prototypes   = prototypes
		end
		
		
		
		
		return document
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
	
	
	
	
	
	def write_data(packed_array, filename)
		path = File.join(@project_directory, filename)
		
		extension = ".csv"
		path += extension
		
		
		# write data to CSV
		CSV.open(path, "wb") do |csv|
			packed_array.each do |data|
				csv << data
			end
		end
	end
	
	def write_yaml_file(data, filename)
		path = File.join(@project_directory, filename)
		
		extension = ".yaml"
		path += extension
		
		
		File.open(path, 'w') do |f|
			f.puts YAML::dump(data)
		end
	end
	
	
	class << self
		# NOTE: all read function helpers have to be at class-level, because they need to be called in the load method
		private
		
		def unpack_with_class_name(array)
			# array format: same as the output to #pack_with_class_name
			klass_name = array.shift
			args = array
			
			klass = Kernel.const_get klass_name
			
			return klass.unpack *args
		end
		
		
		
		
		
		def read_data(project_directory, filename)
			path = File.join(project_directory, filename)
			
			extension = ".csv"
			path += extension
			
			
			# it's not actually an array of arrays, but CSV::Table has a similar interface
			arr_of_arrs = CSV.read(path,
							:headers => false, :header_converters => :symbol, :converters => :all
							)
			
			return arr_of_arrs
		end
		
		
		def load_yaml_file(project_directory, filename)
			path = File.join(project_directory, filename)
			
			extension = ".yaml"
			path += extension
			
			return YAML::load_file path
		end
	end
end


end







# returns a Proc which will be used as a block by #map! to perform replacement
def replace_according_to(conversion_table)
	Proc.new do |input|
		output = conversion_table[input]
		output ? output : input
	end
end