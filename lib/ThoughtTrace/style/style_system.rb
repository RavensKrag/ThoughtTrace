module ThoughtTrace
	module Style


# This class wraps the other elements of the Style system up one place
# which makes things much easier to serialize
# Just tell this object to be serialized, and it will generate a directory
# with all the proper files within it.
class StyleSystem
	attr_reader :path_to_project_root
	attr_reader :pallets, :cascades
	
	def initialize(project_root)
		# this should be the path to the directory where the data
		# for this ThoughtTrace instance is saved
		# NOT the root of the ThoughtTrace gem codebase.
		@path_to_project_root = project_root
		
		@pallets  = Hash.new
		@cascades = Hash.new
	end
	
	def ==(other)
		return (
			@path_to_project_root == other.path_to_project_root and
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
		
		
		
		return @path_to_project_root, pallets, cascades
	end
	
	
	class << self
		def unpack(data)
			path_to_root, pallets, cascades = data
			
			obj = self.new path_to_root
			
			
			
			pallets.each do |name, data|
				pallet = ThoughtTrace::Style::Pallet.unpack data
				
				obj.pallets[name] = pallet
			end
			
			
			cascades.each do |name, data|
				pallet_name, *style_names = data
				
				# TODO: need to be able to get pallets from other files
				pallet = obj.pallets[pallet_name]
				
				
				cascade = ThoughtTrace::Style::Cascade.new pallet
				style_names.each{ |s|  cascade.add s }
				
				obj.cascades[name] = cascade
			end
			
			return obj
		end
	end
	
	
	
	
	def dump
		
	end
	
	class << self
		def load
			
		end
	end
end



end
end