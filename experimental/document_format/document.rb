module ThoughtTrace



class Document
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
		
		
		
		# =======================================
		# =======================================
		# collect style components
		style_components = entities.collect{ |e| e[:style]  }.compact!
		
		
		
		# --- part 1
		# collect all style objects
		all_style_objects = Array.new
		
			style_components.each do |style_component|
				style_component.each_cascade do |cascade_name, cascade|
					# TODO: implement #each_cascade for style component
					cascade.each do |style|
						all_style_objects << style # pseudo-return
					end
				end
			end
		
		# dump style data
		style_object_dump = all_style_objects.collect{ |component| component.dump  }
		
		
		# generate mapping between styles and IDs
		style_to_id_table = all_style_objects.each_with_index.map{|x,i| [x,i]}.to_h
		
		
		# --- part 2
		# dump cascades
		style_component_dump = style_components.collect{ |component| component.dump  }
		# TODO: implement #dump for style component
			
		
		# replace style objects with IDs as necessary
		# (modification happens in-place)
		# (this is doable because arrays are passed by reference)
		style_component_dump.each do |component_data|
			component_data.each do |mode_name, style_list|
				style_list.collect! do |style_obj|
					style_to_id_table[style_obj]
				end
			end
		end
		
		# --- part 3
		# save data to disk
		style_component_dump
		style_object_dump
		# =======================================
		# =======================================
		
		
		
		
		
		
		
		
		
		entity_to_id_table = entities.each_with_index.map{|x,i| [x,i]}.to_h
		
		
		
		
		# TODO: serialize style system
		# TODO: serialize query system
		
		
		
		
		
		# pack entities
		
		# pack all other data
		# use conversion table to replace entity entries with IDs in all but main entity blob
		
		# write entities to disk
		# write all other data to disk
		
		
		
		
		
		
		[groups, constraints].each do |list|
			# pack
			packed_array = list.collect{ |obj| pack_with_class_name(obj)  }.compact!
			
			# replace entities with IDs (non-Entity entries should remain unmodified)
			packed_array.map! do |arg|
				id = entity_to_id_table[arg]
				id ? id : arg
				# TODO: find a better way to map, such that nil / falsey returns will result in the structure being unchanged
				# (or just consider using an actual database backend, so that you can do this properly and don't have this problem)
			end
			
			
			
			# TODO: need to replace in such a way that you know the IDs you are inserting are entity identification keys
			# when you do the replacement at this level, it's harder to tell that you're inserting IDs. how will you know when you read the data back? is it based on schema? the coupling can get confusing here
			packed_array = replace(entity_to_id_table, packed_array)
		end
		
		
		
		# TODO: consider that groups (and / or other types) may be nested, and thus you have do this this normalization-join business on them as well. so you might have to move the replacement block outside of the current loop
		# (but seriously, if you can get the entities collection to be fixed schema, maybe you should use a database)
		# (well, really I mean "if you can get everything to be fixed schema", but the whole not knowing what's up is why I'm using CSV and not a "real" database)
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
end


end