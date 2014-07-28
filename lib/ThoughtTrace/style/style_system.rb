module ThoughtTrace
	module Style


# This class wraps the other elements of the Style system up one place
# which makes things much easier to serialize
# Just tell this object to be serialized, and it will generate a directory
# with all the proper files within it.
class StyleSystem
	def initialize(project_root)
		# this should be the path to the directory where the data
		# for this ThoughtTrace instance is saved
		# NOT the root of the ThoughtTrace gem codebase.
		@path_to_project_root = project_root
		
		@pallets  = Hash.new
		@cascades = Hash.new
	end
	
	def add_pallet(name, pallet)
		@pallets[name] = pallet
		
		return pallet
	end
	
	def add_cascade(name, cascade)
		@cascades[name] = cascade
		
		return cascade
	end
	
	
	def get_pallet(name)
		return @pallets[name]
	end
	
	def get_cascade(name)
		return @cascades[name]
	end
	
	
	
	
	def pack
		# note that cascades are linked to pallets (the cascade objects contain references)
		# need to turn these references into serializable links
		
		value_data = @pallets.values.collect{ |p|  p.pack }
		pallets = @pallets.keys.zip(value_data).to_h
		
		
		
		
		pallet_lookup_table = @pallets.invert
		# p pallet_lookup_table
		
		
		
		
		keys = @cascades.keys
		vals = @cascades.values.collect{ |c| [pallet_lookup_table[c.pallet]] + c.pack }
		cascades = keys.zip(vals).to_h
		
		
		
		return @path_to_project_root, pallets, cascades
	end
	
	
	class << self
		def unpack(data)
			path_to_root, pallets, cascades = data
			
			obj = self.new path_to_root
			
			
			
			
			
			pallet_lookup_table = Hash.new
			pallets.each do |data|
				p = ThoughtTrace::Style::Pallet.unpack data
				
				self.add_pallet p
				
				
				name, collection = data
				pallet_lookup_table[name] = p
			end
			
			
			
			cascades.each do |data|
				name, path_to_root, *styles = data
				
				pallet =
					if path_to_root == "__FILE__"
						pallet_lookup_table[name]
					else
						raise "DON'T KNOW WHAT TO DO. How do you get a pallet from another file?"
					end
				
				
				c = ThoughtTrace::Style::Cascade.new 
			end
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