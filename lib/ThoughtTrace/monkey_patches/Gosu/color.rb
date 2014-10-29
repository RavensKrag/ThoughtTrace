module Gosu


class Color
	def to_s
		"0x"+self.pack.to_s(16)
	end
	
	def inspect
		a,r,g,b = [self.alpha, self.red, self.green, self.blue]
		"#<#{self.class}:#{object_space_id_string} alpha:#{a} red:#{r} green:#{g} blue:#{b}>"
	end
	
	
	def ==(other)
		return false unless other.is_a? self.class
		
		[:alpha, :red, :green, :blue].all?{ |x| self.send(x) == other.send(x) }
	end
end



end