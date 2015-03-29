e = Entity.new
data = e.pack
  => [Entity, style_object, a,b,c,d]

style_object
# later you need to replace this object with an ID so that you can write it to the disk
# there's already at least one system that uses this style, so it's not that big of a deal




# so now we try to build the replacement table
# (not sure if it's better to place elements into a Set as you find them, or find all the elements, and then reduce the collection to just the unique elements)
styles = Set.new



def foo(component_name, list)
	block = Proc.new{ |e| e[component_name]   }

	entity_partition    = list.select(&block).compact  # selection
	relevant_components = entity_partition.collect(&block) # extraction
	
	return relevant_components
end


a = foo(:style, entities)
b = foo(:style, visualizations)
c = foo(:style, groups)

id_to_style_map = (a + b + c).uniq



 
# or do it via mapcat
class Array
	# 'smush' removes duplicates AND nils
	# (basically the ultimate cleanup method)
	
	
	# this is currently the optimal definition of smush,
	# because #compact just duplicates the array and then calls compact!
	def smush
		out = self.uniq
		out.compact!
		
		return out
	end
	
	def smush!
		self.uniq!
		self.compact!
	end
end

collection = [entities, visualizations, groups].flat_map{ |x|  x[:style] }
id_to_style_map = collection.smush # no duplicates or nils





style_to_id_map = id_to_style_map.each_with_index.to_h
