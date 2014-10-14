module ThoughtTrace



# TODO: give this class a more descriptive name
# Access particular Style objects by name.
# These style objects do not have to exist anywhere within the Space.
# They are not necessarily tied to any sort of spatial data.
# NOTE: you really only have to serialize a list of styles, because the style objects have names embedded in them. However, storing them in memory inside a hash makes for faster lookup..
class StyleCollection
	def initialize
		@cache = Hash.new
	end
	
	
	# add a style object to the collection
	def add(style)
		@cache[style.name] = style
	end
	
	# find a style by name
	def [](name)
		raise "No style found with that name" unless @cache.include? name
		
		return @cache[name]
	end
	
	
	
	
	
	# NOTE: this iteration code exists to make the packing of this collection easier from the perspective of the 'document.rb' file
	def each(&block)
		@cache.each do |key, value|
			block.call value
		end
	end
	
	include Enumerable
	
	
	
	
	
	
	def pack
		styles = @cache.collect{ |name, style| style  }
		styles.collect{ |s| s.pack  }
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