module ThoughtTrace



class Builder
	def initialize(document)
		@document = document
	end
	
	def pack(entity_list, component_name)
		block = Proc.new{ |e| e[component_name]   }
		
		
		entity_partition = entity_list.select(&block).compact # selection
		relevant_components = entity_partition.collect(&block) # extraction
		
		obj_list = extract_core_objects(relevant_components)
		obj_dump = pack_core_objects(obj_list)
		
		
		id_mapping = obj_to_id_table(core_object_list)
		
		component_dump = replace_object_with_ids!(pack_components(relevant_components), id_mapping)
		
		
		
		
		# --- save to disk
		
		# need to save some sort of mapping,
		# to know how to link Entity objects
		# with the core backend data
		entity_data_join_table = generate_join_table(entity_partition, component_dump, obj_dump)
		
		# TODO: consider replacing component entries in the join table with IDs? or just figure out if you need to return both the join table, and the raw component data
		
		
		return {
			:join_table        => entity_data_join_table, # component data AND associated Entity
			:component_data    => component_dump,         # component data only
			:core_object_data  => obj_dump                # backend data is super important
		}
	end
	
	
	
	
	def extract_core_objects
		return []
	end
	
	def pack_core_objects(core_object_list)
		core_object_list.collect{ |obj| obj.pack  }
	end
	
	def obj_to_id_table(core_object_list)
		return core_object_list.each_with_index.to_h # general pattern, but not always exact
	end
	
	def pack_components(component_list)
		component_list.collect{ |component| component.pack  }
	end
	
	# perform in-place replacement
	# (this is doable because arrays are passed by reference)
	def replace_object_with_ids!(component_dump, id_mapping)
		return component_dump
	end
	
	def generate_join_table(entity_list, component_dump_list, obj_dump_list)
		return entity_list.zip(component_dump_list) # general pattern, but not always exact
	end
end



class StyleBuilder < Builder
	def pack(entity_list)
		super(entity_list, :style)
	end
	
	
	
	def extract_core_objects(component_list)
		all_style_objects = Array.new
		
		component_list.each do |style_component|
			style_component.each_cascade do |cascade_name, cascade|
				# TODO: implement #each_cascade for style component
				cascade.each do |style|
					all_style_objects << style # pseudo-return
				end
			end
		end
		
		return all_style_objects
	end
	
	def obj_to_id_table(core_object_list)
		(@document.loose_styles + all_style_objects).each_with_index.to_h
	end
	
	# perform in-place replacement
	def replace_object_with_ids!(component_dump, id_mapping)
		component_dump.each do |component_data|
			component_data.each do |mode_name, style_list|
				style_list.collect! do |style_obj|
					id_mapping[style_obj]
				end
			end
		end
	end
end



class QueryBuilder < Builder
	def pack(entity_list)
		super(entity_list, :query)
	end
	
	
	
	def extract_core_objects(component_list)
		component_list.collect{ |component| component.callbacks  }
	end
	
	def obj_to_id_table(core_object_list)
		core_object_list.each_with_index.to_h
	end
	
	# perform in-place replacement
	def replace_object_with_ids!(component_dump, id_mapping)
		component_dump.collect! do |component_data|
			# well, currently the data is just one value, which is the query object
			id_mapping[component_data]
		end
	end
end


end