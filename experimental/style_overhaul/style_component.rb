module Components



class Style
	def initialize
		@active_mode = :default
		
		@cascades = {
			:default => Cascade.new
		}
		@active_cascade = @cascades[@active_mode]
	end
	
	def mode=(mode_name)
		@active_mode = mode_name
		@active_cascade = @cascades[@active_mode]
	end
	
	def mode
		@active_mode
	end
	
	
	
	def primary
		return @active_cascade.primary
	end
	
	delegate to: :@active_cascade,
			 methods:[:read, :write, :socket, :each_style, :move, :move_up, :move_down]
end


end