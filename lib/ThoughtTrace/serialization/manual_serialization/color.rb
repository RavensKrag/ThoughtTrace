# NOTE: this pack is different because it returns a single integer, rather than a list. (Though I suppose the list return is just a explicit multiple return statement. It's not like the unpack ever takes in an actual array. It always takes a fixed number of arguments)

module Gosu


class Color
	def pack
		color = (self.alpha << 8*3) |
				(self.red   << 8*2) |
				(self.green << 8*1) |
				(self.blue  << 8*0)
		
		return color
	end
	
	class << self
		def unpack(argb_hex_number)
			return self.argb argb_hex_number
		end
	end
end



end