require 'fileutils'

require 'csv'
require 'yaml'

module ThoughtTrace



class Document
	# do a list of things,
	# specific implementations for actions can be answered by particular collections
	# (builder pattern)
	
	def dump(path_to_folder=nil)
		@project_directory = File.expand_path path_to_folder if path_to_folder
		# output to the currently stored directory, unless an argument is specified.
		# In which case, use that directory instead.
		# (think of the latter case as 'save as')
		
		
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
				
				
				# NOTE: must first treat EntityList like an array before generating IDs for serialization
				# entity_to_id_table = entities.each.to_a.each_with_index.to_h
				entity_to_id_table = entities.each.with_index.to_h
			
			
			# components (style and query)
			component_data = component_pack(entities, entity_to_id_table)
			write_yaml_file(component_data, 'components')
			
			
			# groups
			groups = @space.groups
			packed_array = groups.pack
			replace_entities_with_ids(packed_array, entity_to_id_table)
			write_data(packed_array, 'groups')
			
			
			# visualizations
			visualizations = @constraint_packages.collect{|x| x.visualization }.uniq
			visualization_to_id_table = visualizations.each_with_index
										.collect{|x,i| [x,"V#{i}"]}.to_h
			
			
			# constraint objects
			constraint_data = @constraint_objects.pack
			write_yaml_file(constraint_data, 'constraints')
			
			
			# constraint packages
			constraint_to_uuid_table = @constraint_objects.map_data_to_uuids
			
			
			constraint_dump = @constraint_packages.pack
			replace_data_with_ids!(
				constraint_dump,
				entity_to_id_table, constraint_to_uuid_table, visualization_to_id_table
			)
			write_data(constraint_dump, 'constraints')
			
			
			
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
	
	
	
	def replace_data_with_ids!(data_dump, entity_to_id, constraint_to_uuid, visualization_to_id)
		truth_replacement = {
			'true' => true,
			'false' => false
		}.invert
		
		# data_dump.each{ |data| data.map! &replace_according_to(entity_to_id)  }
		# data_dump.each{ |data| data.map! &replace_according_to(constraint_to_uuid)  }
		# data_dump.each{ |data| data.map! &replace_according_to(visualization_to_id)  }
		# data_dump.each{ |data| data.map! &replace_according_to(truth_replacement)  }
		
		
		data_dump.collect! do |row|
			out = Array.new(row.size)
			
			row.each_with_index do |x, i|
				# constraint package format:
					# marker_a              entity id   0
					# marker_b              entity id   1
					# a                     entity id   2
					# b                     entity id   3
					# constraint_object     UUID        4
					# visualization         'V' + id    5
					# visible?              boolean     6
				
				conversion_table = case i
					when 0..3
						entity_to_id
					when 4
						constraint_to_uuid
					when 5
						visualization_to_id
					when 6
						truth_replacement
				end
				
				out[i] = conversion_table[x]
			end
			
			out
		end
	end
	
	public
	
	
	
	
	
	
	# ===================================================================================
	# ===================================================================================
	# ===================================================================================
	
	
	
	
	
	def load(path_to_folder)
		# TODO: consider making this #load in the new collection #unpack style: should load into an already initialized object, rather than returning a new one.
		
		@project_directory = File.expand_path path_to_folder
		
		
		# === if project has not yet been created, populate directory based on template data
		unless File.exists? @project_directory
			template_path = File.expand_path './bin/data/empty_data', ThoughtTrace::PATH_TO_ROOT
			
			FileUtils.cp_r(template_path, @project_directory)
		end
		
		
		
		# === load data from disk
		# read data off the disk, using appropriate format => store in dump
		# unpack the dump, loading the data into the appropriate collection
			# this is a polymorphic process,
			# meaning each collection can handle things a little differently if it needs to
		# data is loaded into an collection that has already been allocated,
			# so there is no need to bind the collection to a variable: it's already done
		
		
		
		# NOTE: Contrary to what you might think, the order of loading is the same as the order of dumping. Had originally thought they would be the inverse of each other, but that does not seem to be the case.
		
		
		
		# entities
		entity_dump = read_data("entities")
		
		entities = @space.entities
		entities.unpack(entity_dump)
		
		# NOTE: must first treat EntityList like an array before generating IDs for serialization
		# id_to_entity_table = entities.each.to_a.each_with_index.to_h.invert
		id_to_entity_table = entities.each.with_index.to_h.invert
		
		
		# components
		component_dump = load_yaml_file('components')
		unpack_component_data(component_dump, id_to_entity_table)
		
		# TODO: make sure that this value does not get set to nil when no data is loaded. or crashes. or anything bad like that
		@named_styles  = component_dump[:style][:named_styles]
		
		
		
		
		# groups
		group_data = read_data('groups')
		group_data.each{ |data| data.map! &replace_according_to(id_to_entity_table)  }
		
		groups = @space.groups
		groups.unpack(group_data)
		
		
		# visualizations
		# NOTE: hold visualizations in a temporary collection, and then patch them into the constraint package data dump before passing THAT to the package collection #unpack.
		# visualization_data = 
		# visualizations = unpack_constraint_visualizations(visualization_data)
		visualizations = [
			ThoughtTrace::Constraints::Visualizations::SingleArrow.new
		]
		
		id_to_visualization_table = visualizations.each_with_index
										.collect{|x,i| [x,"V#{i}"]}.to_h
										.invert
		
		
		# constraint objects
		# TODO: make sure that linked constraint closures can be saved correctly
			# current structure means that two Constraints CAN share a closure, but it's not exactly standard. It would only make sense if you want to share between disparate types of Constraints, because otherwise you would just share the whole Constraint object.
		# TODO: really need to think about how new constraints will be formed in the graph.
		
		constraint_data = load_yaml_file('constraints')
		@constraint_objects.unpack(constraint_data)
		define_constraint_closures() # defined in core document file
		
		
		
		# constraint packages
		uuid_to_constraint_table = @constraint_objects
		
		
		data_dump = read_data('constraints')
		
		replace_ids_with_data!(
			data_dump, 
			id_to_entity_table, uuid_to_constraint_table, id_to_visualization_table
		)
		# p data_dump.collect{|row| row.collect{|x|  x.class }}
		
		
		@constraint_packages.unpack(data_dump)
		
		
		
		
		
		
		
		
		
		# TODO: should add a new Constraint object to the list of available ones, and then Package a Constraint selected from that list. Want to potentially reuse Constraint objects among multiple Pairs / Packages.
		# constraint    = ThoughtTrace::Constraints::LimitHeight.new
		# visualization = ThoughtTrace::Constraints::Visualizations::SingleArrow.new
		
		# package = ThoughtTrace::Constraints::Package.new(constraint, visualization)
		
		# package.marker_a[:physics].body.p = CP::Vec2.new(-12.5,-101)
		# package.marker_b[:physics].body.p = CP::Vec2.new(223,-76)
		
		# add_constraint(package)
		
		
		
		
		
		# --- abstract types
		# prototypes
		prototype_data = read_data('prototypes')
		@prototypes.unpack prototype_data
		
		# prefabs
			# PREFAB SYSTEM HAS NOT YET BEEN IMPLEMENTED
			
			
		# loose styles
		# ----
		
		
		
		return self
	end
	
	private
	
	def add_constraint(package)
		constraint = package.constraint
		
		# store constraint object, and generate an associated UUID
		uuid = @constraint_objects.add constraint
		
		
		# make copy of template file
		# replace UUID and CONSTRAINT_CLASS strings from the template with actual values
		# write the new closure file to the disk
		template_filepath = File.expand_path "./closures/template", @project_directory
		
		data = File.read(template_filepath)
		data.gsub! /UUID/,              uuid
		data.gsub! /CONSTRAINT_CLASS/,  constraint.class.name
		
		path = File.expand_path "./closures/#{uuid}.rb", @project_directory
		File.write(path, data)
		
		
		
		
		
		# store package
		@constraint_packages.add package
		
		
		# add Marker objects to Space
		@space.entities.add package.marker_a
		@space.entities.add package.marker_b
	end
	
	def delete_constraint(package)
		# remove package from collection
		@constraint_packages.delete package # TODO: implement PackageCollection#delete
		
		# remove markers from Space
		@space.entities.delete package.marker_a
		@space.entities.delete package.marker_b
		
		
		# if there are no other Packages using that constraint
			# delete constraint object from backend collection
			# delete constraint parameterization file (try to trash it instead of hard delete)
		constraint = package.constraint
		count = @constraint_objects.delete constraint # remove and decrement resource count
		# TODO: implement @constraint_objects#delete with resource counting
		if count == 0
			# No more users of this Constraint object. It has been removed from the collection.
			
			# TODO: need a way of getting the UUID when you have a Constraint object
			uuid = constraint.uuid # NOTE: not implemented. not sure if I want this interface.
			path = File.expand_path "./closures/#{uuid}.rb", @project_directory
			FileUtils.rm(path)
			# TODO: try to move to trash instead of using RM
		end
	end
	
	
	
	def unpack_component_data(data, id_to_entity_table)
		# load component data from disk
		# separate hashes out into relevant parts as necessary
		# copy component data back onto the corresponding entities (use the id -> entity table)
		# (no need to store component data anywhere other than on the entities)
		
		# NOTE: this currently won't exactly work, because the 'Shared Query Style' is currently being saved in both the Style dump and the Query dump. So, that needs to be resolved, otherwise this will get really weird.
		
		
		style_data = data[:style]
		query_data = data[:query]
		
		
		
		[style_data, query_data].collect{ |x| x[:components]  }.each do |component_map|
			component_map.each do |entity_id, component|
				entity = id_to_entity_table[entity_id]
				
				
				if entity.nil?
					puts
					puts "===== DATA DUMP ======================="
					puts "iterating through component map..."
					# all components in one list are the same type
					puts component_map.values.first.class
					# p id_to_entity_table.collect{|id,e|  [id, e.class] }.to_h
					
					puts "component map entity IDs"
					p component_map.keys
					puts
					puts "all available entity IDs"
					p id_to_entity_table.keys
					
					raise KeyError, 
						"Entity with ID #{entity_id} found in Component map, but not Entity list. Data dump above, traceback below."
				end
				
				attach_component(entity, component)
			end
		end
	end
	
	# Either add the component to the Entity, or simply copy the relevant data over
	def attach_component(entity, component)
		interface = component.class.interface
		
		existing_component = entity[interface]
		if existing_component
			entity.delete_component(interface)
		end
		
		entity.add_component(component)
	end
	
	
	def replace_ids_with_data!(data_dump, id_to_entity, uuid_to_constraint, id_to_visualization)
		truth_replacement = {
			'true' => true,
			'false' => false
		}
		
		# data_dump.each{ |data| data.map! &replace_according_to(id_to_entity)  }
		# data_dump.each{ |data| data.map! &replace_according_to(uuid_to_constraint)  }
		# data_dump.each{ |data| data.map! &replace_according_to(id_to_visualization)  }
		# data_dump.each{ |data| data.map! &replace_according_to(truth_replacement)  }
		
		
		data_dump.collect! do |row|
			out = Array.new(row.size)
			
			row.each_with_index do |x, i|
				# m1, m2, e1, e2, constraint_uuid, visualizations_id, visibility
				
				conversion_table = case i
					when 0..3
						id_to_entity
					when 4
						uuid_to_constraint
					when 5
						id_to_visualization
					when 6
						truth_replacement
				end
				
				out[i] = conversion_table[x]
			end
			
			out
		end
	end
	
	public
	
	
	
	
	
	
	
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
	
	
	def load_yaml_file(filename)
		path = File.join(@project_directory, filename)
		
		extension = ".yaml"
		path += extension
		
		return YAML::load_file path
	end
end


end
