module ThoughtTrace



# TODO: figure out if there is a way the abstract types can be loaded without firing up the entire Space. This would be very useful for loading styles / prefabs from one Document in another Document
class Document
	attr_reader :space, :prototypes, :prefabs, :loose_styles
	attr_accessor :project_directory
	
	def initialize
		@space = ThoughtTrace::Space.new
			# style component
			# entity
			# group
			# constraint
		
		@prototypes   = ThoughtTrace::CloneFactory.new    # create copies of simple entities
		@prefabs      = ThoughtTrace::PrefabFactory.new   # spawn complex entity types
		@loose_styles = ThoughtTrace::StyleCollection.new # styles not bound to physical entities
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
	end
	
	
	
	
	
	
	
	# do a list of things,
	# specific implementations for actions can be answered by particular collections
	# (builder pattern)
	
	def dump(path_to_folder)
		entities              = @space.entities
		
		groups                = @space.groups
		constraints           = @space.constraints
		
		styled_entities       = @space.entites.select{ |e|  e[:style] }.compact!
		query_marked_entities = @space.entites.select{ |e|  e[:query] }.compact!
		# NOTE: compact! removes nil entries
		
		
		
		# these objects can just be saved
		# need to get IDs for them so I can reference these records from the other documents
		@prototypes
		@prefabs
		@loose_styles
		
		# TODO: serialize the 'abstract types': prototypes, prefabs, and loose styles
		# NOTE: entries in the Entity list may be of a basic entity type, or they may be of a prefab type. Not sure how that will effect the current systems.
		
		
		
		
		@project_directory = 
		# pack entities
		
		# pack all other data
		# use conversion table to replace entity entries with IDs in all but main entity blob
		
		# write entities to disk
		# write all other data to disk
		
		
		# TODO: consider renaming variables with 'dump' in the name
		# NOTE: This segment of the code uses 'dump' in variable names to refer to 'lists of packed objects'. This can be confusing, as 'dump' generally means "write to file on disk" and 'pack' generally means "take the data from this object, and put it into an array"
		
		entity_dump = entities.collect{ |e| pack_with_class_name(e)  }
			write_data(entity_dump, "entities.csv")
		
		
		entity_to_id_table = entities.each_with_index.to_h
		
		
		
		
		
		
		['style', 'query'].each do |type|
			klass = ThoughtTrace.const_get("#{type.capitalize}Builder")
			data_dump = klass.new(self).pack(entities)
			
			data_dump[:join_table].collect! do |entity, component_dump|
				[entity_to_id_table[entity], component_dump].flatten!
			end
			
			
			
			write_data(data_dump[:join_table],       "#{type}_component.csv")
			write_data(data_dump[:core_object_data], "#{type}_object_data.csv")
		end
		
		
		# NOTE: probably need to do entity -> id replacement as well, or something
		# TODO: need to write some code to attach a style component to an existing Entity
		
		# TODO: write style component dump
		# TODO: write style object dump
		# TODO: write query component dump
		# TODO: write query object dump (entity serialization build system may work here)
		
		
		
		
		{
			'groups'      => groups,
			'constraints' => constraints
		}.each do |type, list|
			# pack
			packed_array = list.collect{ |obj| pack_with_class_name(obj)  }.compact!
			
			# replace entities with IDs (non-Entity entries should remain unmodified)
			packed_array.map! do |arg|
				id = entity_to_id_table[arg]
				id ? id : arg
			end
			# TODO: find a better way to map, such that nil / falsey returns will result in the structure being unchanged
			# (or just consider using an actual database backend, so that you can do this properly and don't have this problem)
			# (in that case, you would probably retain the IDs on the objects, so you wouldn't have THIS problem
			# (but you may have a similar issue with converting from objects -> records)
			
			write_data(packed_array, "#{type}.csv")
		end
		
		
		
		
		
		
		
		
		
		
		
		
		prototype_dump = @prototypes.collect{ |entity| pack_with_class_name(entity)  }
			write_data(prototype_dump, "prototypes.csv")
		
		
		# not sure that I can even begin to figure out how to dump the prefabs
		# when I don't even completely understand what they are yet
		# other than to say they are Groups that have been abstracted,
		# turned into full classes with methods and state,
		# although kept as anonymous classes so they can be easily edited
		prefab_dump = @prefabs
			# write_data(prefab_dump, "prefabs.csv")
		
		# to finalize the dumping of loose styles,
		# the way these styles are retrieved must be considered
		# Styles attached to spatial entities can be retrieved spatially,
		# but non-spatial data must be referenced by name, 
		# or recovered by searching for some property of the data.
		# These styles should probably have names
		# (which is why this should probably be named the "named style" collection)
		# 
		# But wait, don't Style objects always have a name field?
		# Then this really is just a list of styles, and nothing more.
		loose_style_dump = @loose_styles.collect{ |obj| obj.dump  }
			write_data(loose_style_dump, "styles.csv")
		# NOTE: this collection should probably enforce the concept of not containing more than one Style with the same name. That could get really messy
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
			return obj.pack(*args).unshift(obj.class.name)
			# [class_name, arg1, arg2, arg3, ..., argn]
		else
			return nil
		end
	end
	
	
	def write_data(packed_array, filename)
		full_path = File.join(@project_directory, filename)
		
		CSV.open(full_path, "wb") do |csv|
			packed_array.each do |data|
				csv << data
			end
		end
	end
	
	def read_data(filename)
		full_path = File.join(@project_directory, filename)
		
		# it's not actually an array of arrays, but CSV::Table has a similar interface
		arr_of_arrs = CSV.read(full_path,
						:headers => false, :header_converters => :symbol, :converters => :all
						)
		
		return arr_of_arrs
	end
end


end