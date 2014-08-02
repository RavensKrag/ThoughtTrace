module Components



class Style
	def initialize
		@cascade = Cascade.new
		
		
		s1 = StyleObject.new
		@cascade.add s1
	end
end


end