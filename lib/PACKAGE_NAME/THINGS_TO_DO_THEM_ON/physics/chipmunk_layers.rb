module TextSpace
	module Layers
		# List some available constants for Chipmunk layer bitvectors.
		
		# Only objects on the same layer will collide.
		# (uses bitvector logic)
		# 
		# Long version:
		# Objects will collide iff their layers value has at least one overlapping bit plane.
		
		#			  <-- high order bits           low order bits -->
		# CONST_NAME	= "10000000000000000000000000000000".to_i(2)
		FULL_OFF		= "00000000000000000000000000000000".to_i(2)
		FULL_ON			= "11111111111111111111111111111111".to_i(2)
		
		
		CURSOR			= "11111111111111111111111111111111".to_i(2)
		
		UI_ELEMENTS		= "10000000000000000000000000000000".to_i(2)
		ALL_ENTITIES	= "01111111111111111111111111111111".to_i(2)
		QUERIES			= "00000000000000000000000000000001".to_i(2)
		
		
		# ----- bitvector operations -----
			# -- subtraction --
			# formula				bitwise logic
			# a - b = out			a & ~b = out
			
			# | a | b |  out  |
			# -----------------
			# | 0 | 0 |   0   |
			# | 0 | 1 |   0   |
			# | 1 | 0 |   1   |
			# | 1 | 1 |   0   |
			
			# unset the bit if it is set.
			# else, do nothing
			
		# --------------------------------
	end
end