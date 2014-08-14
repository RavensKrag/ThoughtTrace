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
	
	# NOTE: this system is overly simplistic, and may result in weird behavior. consider: both shifts are pressed (true) and then one shift is released (false, but there's still one shift being held). Actually, because the callbacks are run when any sort of button is pressed, it may circumvent this problem. But I suppose maybe that's still bad because it's unintuitive that it would behave that way?
	# BUG CONFIRMED. This implementation does indeed have the problem described
	
	def button_down(id)
		key = @conversion_table[id]
		if key
			@hash[key] = true
		end
	end
	
	def button_up(id)
		key = @conversion_table[id]
		if key
			@hash[key] = false
		end
	end
end



end