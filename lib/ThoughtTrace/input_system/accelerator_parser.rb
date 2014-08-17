module InputSystem


class AcceleratorParser
	def initialize(window, bindings={})
		@window = window
		@bindings = bindings # key symbol => [list, of, key, IDs]
	end
	
	def active_accelerators
		return @bindings.each_key.select{|k| modifier_active?(k)  }
	end
	
	private
	
	def modifier_active?(symbol_name)
		@bindings[symbol_name].any?{ |id|  @window.button_down? id }
	end
end



end