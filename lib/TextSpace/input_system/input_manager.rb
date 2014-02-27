module TextSpace
	module InputSystem


class InputManager
	def intialize
		
	end	
	
	
	
	def button_down(id)
		# ----- Global overrides -----
		$window.close if id == Gosu::KbEscape
		
		
		# ----- Main event parsing -----
		
	end
	
	def button_up(id)
		
	end
	
	
	def shutdown
		
	end
end



end
end