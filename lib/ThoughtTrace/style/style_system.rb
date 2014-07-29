module ThoughtTrace
	module Style


# This class wraps the other elements of the Style system up one place
# which makes things much easier to serialize
# Just tell this object to be serialized, and it will generate a directory
# with all the proper files within it.
class StyleSystem
	attr_reader :pallets, :cascades
	
	def initialize
		@pallets  = Hash.new
		@cascades = Hash.new
	end
	
	def ==(other)
		return (
			@pallets == other.pallets and
			@cascades == other.cascades
		)
	end
	
	
	
	
	def pack
		# note that cascades are linked to pallets (the cascade objects contain references)
		# need to turn these references into serializable links
		
		value_data = @pallets.values.collect{ |p|  p.pack }
		pallets = @pallets.keys.zip(value_data).to_h
		
		
		
		
		pallet_lookup_table = @pallets.invert
		# p pallet_lookup_table
		
		
		
		# TODO: need to be able to be able to link to pallets from other projects as well
		keys = @cascades.keys
		vals = @cascades.values.collect{ |c| [pallet_lookup_table[c.pallet]] + c.pack }
		cascades = keys.zip(vals).to_h
		
		
		
		return pallets, cascades
	end
	
	
	class << self
		def unpack(data)
			pallets, cascades = data
			
			obj = self.new
			
			
			
			pallets.each do |name, data|
				pallet = ThoughtTrace::Style::Pallet.unpack data
				
				obj.pallets[name] = pallet
			end
			
			
			cascades.each do |name, data|
				pallet_name, *style_names = data
				
				# TODO: need to be able to get pallets from other files
				pallet = obj.pallets[pallet_name]
				cascade = ThoughtTrace::Style::Cascade.unpack pallet, style_names
				
				obj.cascades[name] = cascade
			end
			
			return obj
		end
	end
	
	
	
	
	RELATIVE_PALLET_DATAPATH  = File.join '.', 'style', 'pallets.out'
	RELATIVE_CASCADE_DATAPATH = File.join '.', 'style', 'cascades.out'
	
	def dump(base_directory)
		data = self.pack
		pallet_data, cascade_data = data 
		
		
		
		
		filepath = File.expand_path RELATIVE_PALLET_DATAPATH, base_directory
		File.open(filepath, 'w') do |f|
			YAML.dump(pallet_data, f)
		end
		
		
		filepath = File.expand_path RELATIVE_CASCADE_DATAPATH, base_directory
		File.open(filepath, 'w') do |f|
			YAML.dump(cascade_data, f)
		end
	end
	
	class << self
		def load(base_directory)
			filepath = File.expand_path RELATIVE_PALLET_DATAPATH, base_directory
			pallet_data = YAML.load_file(filepath)
			
			filepath = File.expand_path RELATIVE_CASCADE_DATAPATH, base_directory
			cascade_data = YAML.load_file(filepath)
			
			
			obj = self.unpack [pallet_data, cascade_data]
			
			return obj
		end
	end
end



end
end