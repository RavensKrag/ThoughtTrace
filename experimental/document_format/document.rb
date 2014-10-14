require 'fileutils'

require 'csv'
require 'yaml'

module ThoughtTrace



# TODO: figure out if there is a way the abstract types can be loaded without firing up the entire Space. This would be very useful for loading styles / prefabs from one Document in another Document
class Document
	attr_reader :space, :prototypes, :prefabs, :named_styles
	attr_accessor :project_directory
	
	def initialize
		@space = ThoughtTrace::Space.new
			# style component
			# entity
			# group
			# constraint
		
		@prototypes   = ThoughtTrace::CloneFactory.new    # create copies of simple entities
		@prefabs      = ThoughtTrace::PrefabFactory.new   # spawn complex entity types
		@named_styles = ThoughtTrace::StyleCollection.new # styles not bound to physical entities
		                                                  # (ex: base query style)
		# @constraints  = ThoughtTrace::ConstraintFactory.new
			# only need to define the constraint factory if constraints can be defined graphically
			# then the constraint factory would be like the prefab factory.
			# Not sure if you would need an equivalent of CloneFactory as well or not
			# (probably not, because constraints should always be applied to some entities on init)
		
		
		
		
		# NOTES:
		# it is possible that all basic entity types will be defined by the core library
		# this means that the clone factory should look for type definitions in the library dir
		# rather than in the project dir
		# 
		# but it might also be nice to allow for user definitions of starting values for entities
		# in which you want to maintain the current behavior, and scan project dir
		
		
		
		
		
		style = ThoughtTrace::Style::StyleObject.new("Shared Query Style")
		style.tap do |s|
			s[:color] = Gosu::Color.argb(0xaa7A797A)
		end
		
		@named_styles.add style
	end
	
	
	
	
	
	
	
	# do a list of things,
	# specific implementations for actions can be answered by particular collections
	# (builder pattern)
	
	def dump(path_to_folder)
		entities              = @space.entities
		
		groups                = @space.groups
		constraints           = @space.constraints
		
		styled_entities       = @space.entities.select{ |e|  e[:style] }.compact!
		query_marked_entities = @space.entities.select{ |e|  e[:query] }.compact!
		# NOTE: compact! removes nil entries
		
		
		
		# these objects can just be saved
		# need to get IDs for them so I can reference these records from the other documents
		@prototypes
		@prefabs
		@named_styles
		
		# TODO: serialize the 'abstract types': prototypes, prefabs, and loose styles
		# NOTE: entries in the Entity list may be of a basic entity type, or they may be of a prefab type. Not sure how that will effect the current systems.
		
		
		
		
		@project_directory = path_to_folder
		# pack entities
		
		# pack all other data
		# use conversion table to replace entity entries with IDs in all but main entity blob
		
		# write entities to disk
		# write all other data to disk
		
		
		# TODO: consider renaming variables with 'dump' in the name
		# NOTE: This segment of the code uses 'dump' in variable names to refer to 'lists of packed objects'. This can be confusing, as 'dump' generally means "write to file on disk" and 'pack' generally means "take the data from this object, and put it into an array"
		
		
		
		
		# move into project directory
		# (create directory if necessary)
		full_path = File.expand_path @project_directory
		Dir.mkdir full_path unless File.directory?(full_path)
		
		Dir.chdir full_path do
			entity_dump = entities.collect{ |e| pack_with_class_name(e)  }
			write_data(entity_dump, "entities.csv")
			
			
			entity_to_id_table = entities.each_with_index.to_h
			
			
			
			
			
			
			
			component_name = :style
			entity_list = entities
			
			block = Proc.new{ |e| e[component_name]   }
			
			
			entity_partition = entity_list.select(&block).compact # selection
			relevant_components = entity_partition.collect(&block) # extraction
			
			
			
			entity_ids = entity_partition.collect{ |e| entity_to_id_table[e]  }
			join = entity_ids.zip(relevant_components).to_h
			
			
			
			data = {
				:named_styles => @named_styles,
				:style_components => join
			}
			write_yaml_file(data, './style.yaml')
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			component_name = :query
			entity_list = entities
			
			block = Proc.new{ |e| e[component_name]   }
			
			
			entity_partition = entity_list.select(&block).compact # selection
			relevant_components = entity_partition.collect(&block) # extraction
			
			entity_ids = entity_partition.collect{ |e| entity_to_id_table[e]  }
			join = entity_ids.zip(relevant_components).to_h
			
			
			data = {
				:query_components => join
			}
			write_yaml_file(data, './query.yaml')
		end
	end
	
	
	def self.load(path_to_folder)
		# === create new document
		document = self.new
		
		
		# === load data from disk
		entity_dump = read_data("entities.csv")
		entities =	entities.each.collect do |row|
						klass_name, *args = row.to_a
						
						klass = ThoughtTrace.const_get(klass_name)
						klass.unpack(*args)
					end
		
		id_to_entity_table = entities
		
		
		
		
		
		
		
		
		# components
		['style', 'query'].each do |type|
			data = Hash.new
			data[:join_table]       = read_data("#{type}_component.csv")
			data[:core_object_data] = read_data("#{type}_object_data.csv")
			
			
			
			data[:join_table].each do |component_data|
				entity_id = component_data.shift
				entity = id_to_entity_table[entity_id]
				
				
				component_class, *component_args = component_data
				component = component_class.unpack(*component_args)
				# NOTE: this means that components are expected to pack the class name. this is not currently how Entities work; their class name packing is handled separately. Need to figure out what approach is best, (or what approach should be used where). Would be best to have consistency.
				# (I think this same assumption is being made for the core object data as well)
				
				
				
				# TODO: attach backend objects up to the components before attaching to the entity
				# NOTE: for queries, this attachment must currently be done on initialization
				component.core_object = 'THIS IS NOT GOING TO WORK'
				
				
				# NOTE: this will work ONLY for query components. many Entity types already have style components. not sure how to update those style components without weird breakage
				entity.add_component component
			end
			
			
			
			
			
			data[:join_table].each do |component_data|
				# substitute entity IDs for actual Entity objects
				entity_id = component_data[0]
				entity = id_to_entity_table[entity_id]
				component_data[0] = entity
			end
			
			
			
			
			
			
			
			
			
			
			
			[entity, [component_dump]]
			component_dump = [component_class, component_data]
			
			[entity, [component_class, component_data]]
			
			
			
			
			
			
			core_data_list = 
				data[:core_object_data].collect do |data_dump|
					class_name = data_dump.shift
					
					klass = Kernel.const_get class_name
					klass.unpack 
				end
			
			
			
			
			
			data[:join_table].each do |component_data|
				entity_id, component_class, *component_args = component_data
				# NOTE: this is not a correct unpacking of this data, because the data is actually nested by one level, rather than being all in one level like this code assumes.
				
				
				
				
				entity = id_to_entity_table[entity_id]
				core_data = 
				
				component = component_class.unpack(*component_args)
				
				entity.add_component component
			end
			
			
		end
		
		
		
		
		
		
		
		
		
		# other stuff that uses entities
		{
			'groups'      => groups,
			'constraints' => constraints
		}
			write_data(packed_array, "#{type}.csv")
		
		
		
		
		
		
		
		# abstract types
			write_data(prototype_dump, "prototypes.csv")
			# write_data(prefab_dump, "prefabs.csv")
			write_data(loose_style_dump, "styles.csv")
		
		# ----
		
		
		
		# === populate the space
		{
			:entities => entities,
			:queries  => queries,
			:groups   => groups
		}.each do |name, collection|
			collection.each{ |obj| document.space.send(name).add obj  } 
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
		# write data to CSV
		CSV.open(filename, "wb") do |csv|
			packed_array.each do |data|
				csv << data
			end
		end
	end
	
	def read_data(filename)
		path = File.join(@project_directory, filename)
		full_path = File.expand_path path
		
		# it's not actually an array of arrays, but CSV::Table has a similar interface
		arr_of_arrs = CSV.read(full_path,
						:headers => false, :header_converters => :symbol, :converters => :all
						)
		
		return arr_of_arrs
	end
	
	
	
	def write_yaml_file(data, filepath)
		File.open(filepath, 'w') do |f|
			f.puts YAML::dump(data)
		end
	end
end


end