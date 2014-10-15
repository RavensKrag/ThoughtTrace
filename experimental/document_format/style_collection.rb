module ThoughtTrace



# TODO: give this class a more descriptive name
# Access particular Style objects by name.
# These style objects do not have to exist anywhere within the Space.
# They are not necessarily tied to any sort of spatial data.
# NOTE: using a list instead of a hash because the names are tied to the Style objects themselves. This makes it easy to change the names from anywhere (very good) but results in ugly cache invalidation problems in this collection. Avoid that by just using an array.
class StyleCollection
	def initialize
		@cache = Array.new
	end
	
	
	# add a style object to the collection
	def add(style)
		raise "Error: style has no name" if style.name == ""
		
		@cache << style
	end
	
	# find a style by name
	# TODO: consider removing the hash-style interface. it may lead to assumptions that this is a constant-time access, like hash or even array
	def [](name)
		style = find{ |style| style.name == name  }
		if style
			return style
		else
			raise "No style found with that name"
		end
	end
	
	
	
	
	extend Forwardable
	# NOTE: this iteration code exists to make the packing of this collection easier from the perspective of the 'document.rb' file
	def_delegators :@cache, :each
	
	include Enumerable
	# defines find
	
	
	
	
	
	def pack
		@cache.collect{ |style| style.pack  }
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