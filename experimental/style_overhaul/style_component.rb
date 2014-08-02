module Components



class Style
	def initialize
		@active_mode = :default
		
		@cascade = Cascade.new
	end
	
	def primary
		return @cascade.primary
	end
	
	
	
	delegate to: :@cascade,
			 methods:[:read, :write, :socket, :each_style, :move, :move_up, :move_down]
end


end