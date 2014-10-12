module ThoughtTrace



class Foo
	def main(entity_list, component_name)
		block = Proc.new{ |e| e[component_name]   }
		
		
		entity_partition = entity_list.select(&block).compact! # selection
		relevant_components = entity_partition.collect(&block) # extraction
		
		obj_list = extract_core_objects(relevant_components)
		obj_dump = dump_core_objects(obj_list)
		
		
		id_mapping = obj_to_id_table(core_object_list)
		
		component_dump = replace_object_with_ids!(dump_components(relevant_components))
		
		
		
		
		# --- save to disk
		# backend data is super important
		obj_dump
		
		# many not need to save components
		component_dump # ignore you get an empty array
		
		
		# need to save some sort of mapping,
		# to know how to link Entity objects
		# with the core backend data
		entity_data_join_table = generate_join_table(entity_partition, component_dump, obj_dump)
		
		# TODO: consider replacing component entries in the join table with IDs? or just figure out if you need to return both the join table, and the raw component data
		
		
		return {
			:join_table        => entity_data_join_table,
			:component_data    => component_dump,
			:core_object_data  => obj_dump
		}
	end
	
	
	
	
	# find desired entities
	def map
		
	end
	
	# extract components
	def extract
		
	end
	
	def extract_core_objects
		return []
	end
	
	def dump_core_objects(core_object_list)
		core_object_list.collect{ |obj| obj.dump  }
	end
	
	def obj_to_id_table(core_object_list)
		return core_object_list.each_with_index.to_h # general pattern, but not always exact
	end
	
	def dump_components(component_list)
		component_list.collect{ |component| component.dump  }
	end
	
	# perform in-place replacement
	# (this is doable because arrays are passed by reference)
	def replace_object_with_ids!(component_dump, id_mapping)
		return component_dump
	end
	
	def generate_join_table(entity_list, component_dump_list, obj_dump_list)
		return entity_list.zip(component_dump_list).to_h # general pattern, but not always exact
	end
end



class StyleFoo < Foo
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
	
	# def dump_core_objects(core_object_list)
		
	# end
	
	def obj_to_id_table(core_object_list)
		(@loose_styles + all_style_objects).each_with_index.to_h
	end
	
	# def dump_components(component_list)
		
	# end
	
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
	
	# def generate_join_table(entity_list, component_dump_list, obj_dump_list)
	# 	return entity_list.zip(component_dump_list).to_h
	# end
end



class QueryFoo < Foo
	def extract_core_objects(component_list)
		component_list.collect{ |component| component.callbacks  }
	end
	
	# def dump_core_objects(core_object_list)
		
	# end
	
	def obj_to_id_table(core_object_list)
		core_object_list.each_with_index.to_h
	end
	
	# def dump_components(component_list)
		
	# end
	
	# perform in-place replacement
	def replace_object_with_ids!(component_dump, id_mapping)
		component_dump.collect! do |component_data|
			# well, currently the data is just one value, which is the query object
			id_mapping[component_data]
		end
	end
	
	# def generate_join_table(entity_list, component_dump_list, obj_dump_list)
	# 	return entity_list.zip(component_dump_list).to_h # general pattern, but not always exact
	# end
end




end