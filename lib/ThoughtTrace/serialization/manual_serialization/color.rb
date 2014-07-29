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