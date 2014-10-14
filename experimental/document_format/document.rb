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
				:components => join
			}
			write_yaml_file(data, 'style')
			
			
			
			
			join = foo[:query]
			
			data = {
				:components => join
			}
			write_yaml_file(data, 'query')
			
			
			
			
			
			
			
			
			
			
			
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
		# === create new document
		document = self.new
		
		
		# === load data from disk
		entity_dump = read_data("entities")
		entities =	entity_dump.each.collect do |row|
						data = row.to_a
						
						klass_name = data.shift
						args = data
						
						klass = ThoughtTrace.const_get(klass_name)
						klass.unpack(*args)
					end
		
		id_to_entity_table = entities
		
		
		
		
		
		
		
		
		# --- components
		# load component data from disk
		# separate hashes out into relevant parts as necessary
		# copy component data back onto the corresponding entities (use the id -> entity table)
		# (no need to store component data anywhere other than on the entities)
		
		data = load_yaml_file('style')
		
		named_styles    = data[:named_styles]
		style_components = data[:components]
		
		
		
		data = load_yaml_file('query')
		
		query_components = data[:components]
		
		
		
		
		[style_components, query_components].each do |component_list|
			component_list.each do |entity_id, component|
				entity = id_to_entity_table[entity_id]
				
				interface = component.class.interface
				# TODO: implement this method
				entity[interface].mirror component
				# a.mirror b
				# would result in A copying the state of B
				# (this is NOT meant to imply that the two objects will be kept in sync)
				# (again, this is a one-time thing)
			end
		end
		
		
		
		
		
		
		
		
		
		# other stuff that uses entities
		types = ['groups', 'constraints']
		out = 
			types.collect do |type|
				data_dump = read_data(type)
				
				data_dump.each{ |data| data.map! &replace_according_to(id_to_entity_table)  }
				
				data_dump.collect{ |data| unpack_with_class_name(data)  }
			end
		other_stuff = types.zip(out).to_h
		
		
		
		
		# abstract types
			
		# ----
		
		
		
		# === populate the space
		{
			:entities => entities,
			:queries  => other_stuff['groups'],
			:groups   => other_stuff['constraints']
		}.each do |name, collection|
			collection.each{ |obj| document.space.send(name).add obj  } 
		end
		
		# === set abstract data types
		document.instance_eval do
			@named_styles = named_styles
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
	
	def unpack_with_class_name(array)
		# array format: same as the output to #pack_with_class_name
		klass_name = array.shift
		args = array
		
		klass = Kernel.const_get klass_name
		
		return klass.unpack *args
	end
	
	
	
	
	# returns a Proc which will be used as a block by #map! to perform replacement
	def replace_according_to(conversion_table)
		Proc.new do |input|
			output = conversion_table[input]
			output ? output : input
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
		
		extension = ".csv"
		path += extension
		
		
		# it's not actually an array of arrays, but CSV::Table has a similar interface
		arr_of_arrs = CSV.read(path,
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