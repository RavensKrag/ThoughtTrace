module Components



class Style
	def initialize
		@cascade = Cascade.new
		
		
		
		s1 = StyleObject.new
		s1[:color] = "GREEN"
		@cascade.add s1
		
		s1 = StyleObject.new
		s1[:color] = "YELLOW"
		@cascade.add s1
		
		s1 = StyleObject.new
		s1[:color] = "RED"
		@cascade.add s1
	end
	
	# Read properties through the Cascade
	def [](property)
		@cascade[property]
	end
	
	# add new style?
end


end