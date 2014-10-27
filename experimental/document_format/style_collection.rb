module ThoughtTrace



# TODO: give this class a more descriptive name
# Access particular Style objects by name.
# These style objects do not have to exist anywhere within the Space.
# They are not necessarily tied to any sort of spatial data.

# Styles added to this collect can not have their names changed once added.
# These names need to be unique identifiers within this collection,
# which can persist even after serialization.
class StyleCollection
	def initialize
		@cache = Hash.new
	end
	
	
	# add a style object to the collection
	def add(style)
		raise "Error: style has no name" if style.name == ""
		
		
		style.lock_name!
		@cache[style.name] = style
	end
	
	# find a style by name
	def [](name)
		style = @cache[name]
		if style
			return style
		else
			raise "No style found with that name"
		end
	end
	
	def style_names
		@cache.keys
	end
	
	
	
	
	
	
	
	def pack
		@cache.values.collect{ |style| style.pack  }
	end
	
	
	def self.unpack(style_dump_list)
		collection = self.new
		
		style_dump_list.each do |style_dump|
			style = ThoughtTrace::Style::StyleObject.unpack(*style_dump)
			collection.add style
		end
		
		return collection
	end
end


end