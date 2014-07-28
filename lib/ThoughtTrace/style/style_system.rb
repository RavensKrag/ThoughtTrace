module ThoughtTrace
	module Style


# This class wraps the other elements of the Style system up one place
# which makes things much easier to serialize
# Just tell this object to be serialized, and it will generate a directory
# with all the proper files within it.
class StyleSystem
	attr_reader :pallets, :cascades
	
	def initialize(project_root)
		# this should be the path to the directory where the data
		# for this ThoughtTrace instance is saved
		# NOT the root of the ThoughtTrace gem codebase.
		@path_to_project_root = project_root
		
		@pallets  = Hash.new
		@cascades = Hash.new
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
		# === Save all pallets
		@pallet_list.each do |pallet|
			name = pallet.name
			root = pallet.project_root
			
			root_of_this_project = '.' # TODO: replace with real filepath logic
			
			# process
			root = '__FILE__' if root == @path_to_project_root
			
			extension = '.yml'
			path_to_file = File.join root, name+extension
			
			
			
			# note, the actually serialization is going to be a bit messier than this
			# because you need to figure out how to serialize types that are not
			# standard to Ruby, and thus not a part of YAML's type system
			File.open(filepath, 'w') do |f|
				YAML.dump(pallet.pack, f)
			end
		end
		
		
		
		
		
		
		# === Save all cascades (uses information from pallets)
		
		# remember that cascades need to reference pallets by name and project root path
		
		pallet_translation_table = 
			@pallet_list.inject(Hash.new) do |hash, pallet|
				hash[pallet] = [pallet.name, pallet.project_root]
				
				hash
			end
		
		@cascade_list.each do |cascade|
			pallet_object = cascade.pallet
			# translate object into [name, path] pair
			
			pallet_name, pallet_path =  pallet_translation_table[pallet_object]
			
			cascade_data = [pallet_path, pallet_name] + cascade.styles.to_a
			
			
			File.open(filepath, 'w') do |f|
				YAML.dump(cascade_data, f)
			end
		end
	end
	
	class << self
		def load
			
		end
	end
end



end
end