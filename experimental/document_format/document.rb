module ThoughtTrace



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
		
		
		
		
		@project_directory = 
		# pack entities
		
		# pack all other data
		# use conversion table to replace entity entries with IDs in all but main entity blob
		
		# write entities to disk
		# write all other data to disk
		
		
		
		entity_dump = entities.collect{ |e| pack_with_class_name(e)  }
		write_data(entity_dump, "entities.csv")
		
		
		entity_to_id_table = entities.each_with_index.to_h
		
		
		
		
		
		
		['style', 'query'].each do |type|
			klass = ThoughtTrace.const_get("#{type.capitalize}Builder")
			data_dump = klass.new(self).main(entities)
			
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
		
		
		
		
		[
			['groups',      groups]
			['constraints', constraints]
		].each do |type, list|
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
	end
	
	
	def self.load(path_to_folder)
		# Create a new space
		space = ThoughtTrace::Space.new
		
		
		entities = ThoughtTrace::Space::EntityList.load path_to_folder, space
		
		id_to_entity_table = entities
		
		
		
		
		
		
		
		
		space.instance_eval do
			@entities    = entities
			@queries     = queries
			# @constraints = constraints
			@groups      = groups
		end
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
end


end