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
		
		styled_entities       = @space.entities.select{ |e|  e[:style] }.compact
		query_marked_entities = @space.entities.select{ |e|  e[:query] }.compact
		# NOTE: compact removes nil entries
		
		
		
		# these objects can just be saved
		# need to get IDs for them so I can reference these records from the other documents
		@prototypes
		@prefabs
		@named_styles
		
		# TODO: serialize the 'abstract types': prototypes, prefabs, and loose styles
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
			
			data = {
				:named_styles => @named_styles,
				:style_components => join
			}
			write_yaml_file(data, 'style')
			
			
			
			join = foo[:query]
			
			data = {
				:query_components => join
			}
			write_yaml_file(data, 'query')
			
			
			
			
			
			
			
			
			
			
			
			{
				'groups'      => groups,
				'constraints' => constraints
			}.each do |type, list|
				# pack
				packed_array = list.collect{ |obj| pack_with_class_name(obj)  }.compact
				
				# replace entities with IDs (non-Entity entries should remain unmodified)
				packed_array.each do |data|
					data.map! do |arg|
						id = entity_to_id_table[arg]
						id ? id : arg
					end
				end
				# TODO: find a better way to map, such that nil / falsey returns will result in the structure being unchanged
				# (or just consider using an actual database backend, so that you can do this properly and don't have this problem)
				# (in that case, you would probably retain the IDs on the objects, so you wouldn't have THIS problem
				# (but you may have a similar issue with converting from objects -> records)
				
				write_data(packed_array, type)
			end
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
			# load component data from disk
			# separate hashes out into relevant parts as necessary
			# copy component data back onto the corresponding entities (use the id -> entity table)
			# (no need to store component data anywhere other than on the entities)
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
	
	def read_data(filename)
		path = File.join(@project_directory, filename)
		full_path = File.expand_path path
		
		# it's not actually an array of arrays, but CSV::Table has a similar interface
		arr_of_arrs = CSV.read(full_path,
						:headers => false, :header_converters => :symbol, :converters => :all
						)
		
		return arr_of_arrs
	end
	
	
	
	def write_yaml_file(data, filename)
		path = File.join(@project_directory, filename)
		
		extension = ".yaml"
		path += extension
		
		
		File.open(path, 'w') do |f|
			f.puts YAML::dump(data)
		end
	end
end


end