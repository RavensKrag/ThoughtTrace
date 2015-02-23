require 'fileutils'

require 'csv'
require 'yaml'

module ThoughtTrace



class Document
	# do a list of things,
	# specific implementations for actions can be answered by particular collections
	# (builder pattern)
	
	def dump(path_to_folder)
		@project_directory = File.expand_path path_to_folder
		
		# TODO: consider renaming variables with 'dump' in the name
		# NOTE: This segment of the code uses 'dump' in variable names to refer to 'lists of packed objects'. This can be confusing, as 'dump' generally means "write to file on disk" and 'pack' generally means "take the data from this object, and put it into an array"
		
		
		# move into project directory
		# (create directory if necessary)
		Dir.mkdir @project_directory unless File.directory?(@project_directory)
		Dir.chdir @project_directory do
			# TODO: do not specify file extension in write function call
			# TODO: change name to abstract the name of format being used
			# (note that CSV is being used for 'lists of lists' and YAML is pretty much just an object dump)
			
			
			
			# entities (includes physics component data)
			entities = @space.entities
			entity_dump = entities.pack
			write_data(entity_dump, "entities")
				# NOTE: entries in the Entity list may be of a basic entity type, or they may be of a prefab type. Not sure how that will effect the current systems.
			
				entity_to_id_table = entities.each_with_index.to_h
			
			
			# components (style and query)
			component_data = component_pack(entities, entity_to_id_table)
			write_yaml_file(component_data, 'components')
			
			
			# groups
			groups = @space.groups
			packed_array = groups.pack
			replace_entities_with_ids(packed_array, entity_to_id_table)
			write_data(packed_array, 'groups')
			
			
			# visualizations
			
			
			# constraints
			
			
			
			
			# --- abstract types ---
			# 
			# TODO: serialize the 'abstract types': prototypes, prefabs, and loose styles
			# prototypes
			prototype_data = @prototypes.pack
			write_data(prototype_data, 'prototypes')
			
			# prefabs
			# PREFAB SYSTEM HAS NOT YET BEEN IMPLEMENTED
			
			
			# loose styles
				# NOTE: @named_styles collection has already been serialized as part of the component system, in order to make sure that Style data is always linked correctly
			# ----
		end
	end
	
	private
	
	def component_pack(entities, entity_to_id_table)
		join = foo(entities, :style, entity_to_id_table)
		
		style_data = {
			:named_styles => @named_styles,
			:components => join
		}
		
		
		
		join = foo(entities, :query, entity_to_id_table)
		
		query_data = {
			:components => join
		}
		
		
		
		component_data = {
			:style => style_data,
			:query => query_data
		}
		
		return component_data
	end
	
	# given a list of lists, replace all Entity references in the inner list with ID numbers
	def replace_entities_with_ids(collection, entity_to_id_table)
		collection.each{ |data| data.map! &replace_according_to(entity_to_id_table)  }
	end
	
	
	# return a map: { entity_id => component }
	# select all components with a certain interface name from the list of entities given
	def foo(entities, component_name, entity_to_id_table)
		# block = Proc.new{ |e| e[component_name]   }
		
		
		# entity_partition = entities.select(&block).compact # selection
		# relevant_components = entity_partition.collect(&block) # extraction
		
		
		# entity_ids = entity_partition.collect{ |e| entity_to_id_table[e]  }
		# join = entity_ids.zip(relevant_components).to_h
		
		# return join
		
		
		hash = Hash.new
			entities.each do |e|
				component = e[component_name]
				if component
					k = entity_to_id_table[e]
					v = component
					
					hash[k] = v
				end
			end
		
		return hash
	end
	
	public
	
	
	
	
	
	
	# ===================================================================================
	# ===================================================================================
	# ===================================================================================
	
	
	
	
	
	class << self
	def load(path_to_folder)
		project_directory = path_to_folder
		
		# === create new document
		document = self.new
		
		
		# === load data from disk
		# read data off the disk, using appropriate format => store in dump
		# unpack the dump, loading the data into the appropriate collection
			# this is a polymorphic process,
			# meaning each collection can handle things a little differently if it needs to
		# data is loaded into an collection that has already been allocated,
			# so there is no need to bind the collection to a variable: it's already done
		
		
		
		# NOTE: Contrary to what you might think, the order of loading is the same as the order of dumping. Had originally thought they would be the inverse of each other, but that does not seem to be the case.
		
		
		
		# entities
		entity_dump = read_data(project_directory, "entities")
		
		entities = document.space.entities
		entities.unpack(entity_dump)
		
		id_to_entity_table = entities.each_with_index.to_h.invert
		
		
		# components
		component_dump = load_yaml_file(project_directory, 'components')
		unpack_component_data(component_dump, id_to_entity_table)
		
		named_styles    = component_dump[:style][:named_styles]
		
		
		
		
		# groups
		group_data = read_data(project_directory, 'groups')
		group_data.each{ |data| data.map! &replace_according_to(id_to_entity_table)  }
		
		groups = document.space.groups
		groups.unpack(group_data)
		
		
		# visualizations
		
		
		
		# constraints
		
		
		
		
		
		
		
		
		# --- abstract types
		# prototypes
		prototype_data = read_data(project_directory, 'prototypes')
		prototypes = document.prototypes
		prototypes.unpack prototype_data
		
		# prefabs
			# PREFAB SYSTEM HAS NOT YET BEEN IMPLEMENTED
			
			
		# loose styles
		# ----
		
		
		
		
		# === set abstract data types
		document.instance_eval do
			# TODO: make sure that this value does not get set to nil when no data is loaded. or crashes. or anything bad like that
			@named_styles = named_styles
			
			# @constraints = constraints
		end
		
		
		
		
		
		return document
	end
	
	private
	
	def unpack_component_data(data, id_to_entity_table)
		# load component data from disk
		# separate hashes out into relevant parts as necessary
		# copy component data back onto the corresponding entities (use the id -> entity table)
		# (no need to store component data anywhere other than on the entities)
		
		# NOTE: this currently won't exactly work, because the 'Shared Query Style' is currently being saved in both the Style dump and the Query dump. So, that needs to be resolved, otherwise this will get really weird.
		
		
		style_data = data[:style]
		query_data = data[:query]
		
		
		
		[style_data, query_data].collect{ |x| x[:components]  }.each do |component_list|
			component_list.each do |entity_id, component|
				entity = id_to_entity_table[entity_id]
				
				attach_component(entity, component)
			end
		end
	end
	
	# Either add the component to the Entity, or simply copy the relevant data over
	def attach_component(entity, component)
		interface = component.class.interface
		
		existing_component = entity[interface]
		if existing_component
			existing_component.mirror component
		else
			entity.add_component component
		end
	end
	
	public
	
	end
	
	
	
	
	
	
	
	private
	
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
