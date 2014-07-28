module ThoughtTrace
	module Style


class Cascade
	def initialize(pallet)
		@styles = Array.new # list of style names
		@pallet = pallet    # pallets manage the actual style data
		# how do you serialize the pallet?
		# is there an ID?
		# is there a name?
		# does the name need to be unique?
		# how to you make sure it's unique?
		# what if you merge two "documents" and you get non-unique pallets?
		# (you should really be able to disambiguate by their differing sources though...)
		
		
		
		
	end
	
	# add a new style to the cascade
	# style elements added later have priority over ones that came before
	# (just like )
	def add(style)
		@styles << style
	end
	
	# search cascade order for a particular property
	def [](property)
		# find the first style object in the cascade order which has the desired property
		style = @styles.reverse_each.find{ |style| style[property] }
		return style[property]
	end
	
	
	
	
	
	def pack
		return [@pallet.name, @pallet.project] + @styles
	end
	
	
	
	
	def inspect
		this_id   = ("0x%014x" % (self.object_id << 1))
		pallet_id = ("0x%014x" % (@pallet.object_id << 1))
		
		
		style_data  = "@styles=#{@styles.inspect}"
		# pallet_data = "@pallet=\"#<#{@pallet.class}:#{pallet_id}>\""
		pallet_data = "@pallet={#{@pallet.project} -> #{@pallet.name}}"
		
		output = "#<#{self.class}:#{this_id} #{pallet_data} #{style_data}>"
		return output
	end
	
	
	
	
	class << self
		def load(filepath)
			list = YAML.load_file(filepath)
			obj = self.unpack list
			
			return obj
		end
	end
	
	def dump(filepath)
		yaml = {:list => list, :pallet => }.to_yaml
		
		File.open(filepath, 'w') do |f|
			YAML.dump(yml, f)
		end
	end
end



end
end