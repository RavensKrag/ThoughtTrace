body
shape




def pack
	data = {
		:body => [body.p.x, body.p.y]
		:shape => [] # probably needs to be different for different shapes?
	}
	
	return data
end


class << self
	def unpack
		
	end
end