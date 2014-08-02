require 'yaml'
require 'securerandom'


module ThoughtTrace
	module Style


class Pallet
	def initialize
		@forward = Hash.new # id    =>  style
		@reverse = Hash.new # style =>  id
	end
	
	
	def ==(other)
		return @forward.all?{ |k,v|  v == other.get_style(k) }
	end
	
	
	
	
	
	
	def add(style)
		id = nil
		begin
			id = generate_id()
		end while(@forward.has_key? id)
		
		
		@forward[id] = style
		@reverse[style] = id
		
		return id
	end
	
	
	
	# delete and access need to be granted both in terms of 
	# id => style   AND   style => id
	
	
	def delete_style(style)
		x = @forward.delete style
		@reverse.delete x
	end
	
	def delete_id(id)
		x = @reverse.delete id
		@forward.delete x
	end
	
	
	
	def get_style(id)
		return @forward[id]
	end
	
	def get_id(style)
		return @reverse[style]
	end
	
	
	# could use fetch() and rfetch() for names?
	# I don't mind preferring one direction over the other,
	# but idk if it's readily apparent which direction is which
	
	
	
	def each(&block)
		@forward.each &block
	end
	
	include Enumerable
	
	
	
	
	# return an array of all styles whose names align contain the query
	def find(regex_or_string)
		search_results = @storage
							.select{   |id, style|  style.name =~ regex_or_string  } # => hash
							.collect{  |id, style|  style.id } # => array
		return search_results
	end
	
	
	
	private
	
	def generate_id
		SecureRandom.uuid
	end
	
	public
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	# is there any reason for StyleObject to be it's own custom class?
	# I kinda don't want arbitrary Hash objects thrown into this collection
	# but there's not really a good way to stop that
	# unless you violate duck typing, in favor of a stricter type system
	# which is kinda bad in the context of Ruby
	
	
	
	def pack
		collection =
			@forward.collect do |id, style|
				[id, style.pack]
			end
		
		collection = collection.to_h
		
		return collection
	end
	
	class << self
		def unpack(property_hash)
			obj = self.new
			
			
			property_hash.each do |style_id, style_data|
				style = ThoughtTrace::Style::StyleObject.unpack style_data
				hash = obj.instance_variable_get :@forward
				hash[style_id] = style
			end
			
			return obj
		end
	end
	
	
	
	
	def dump(filepath)
		data = self.pack
		
		File.open(filepath, 'w') do |f|
			YAML.dump(data, f)
		end
	end
	
	class << self
		def load(filepath)
			data = YAML.load_file(filepath)
			obj = self.unpack data
			
			return obj
		end
	end
end



end
end