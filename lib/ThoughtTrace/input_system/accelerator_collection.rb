module InputSystem


class AcceleratorCollection
	def initialize(*key_conversion_list)
		@conversion_table = Hash.new
		@hash = Hash.new
		
		key_conversion_list.each do |key_symbol, *button_ids|
			button_ids.each do |id|
				@conversion_table[id] = key_symbol
			end
			@hash[key_symbol] = false
		end
	end
	
	def active_accelerators
		@hash.select{ |button_symbol, flag|  flag }.keys
	end
	
	
	def button_down(id)
		key = @conversion[id]
		if key
			@hash[key] = true
		end
	end
	
	def button_up(id)
		key = @conversion[id]
		if key
			@hash[key] = false
		end
	end
end



end