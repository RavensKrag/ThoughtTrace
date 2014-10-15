class Object
	def object_space_id_string
		return ("0x%014x" % (self.object_id << 1))
	end
	
	
	
	
	
	
	class << self
		def delegate(methods:[], to:nil)
			p methods
			p to
			
			methods.each do |method|
				define_method method do |*args|
					obj = self.instance_variable_get to
					obj.send method, *args
				end
			end
		end
		private :delegate
	end
end