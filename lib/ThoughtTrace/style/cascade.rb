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