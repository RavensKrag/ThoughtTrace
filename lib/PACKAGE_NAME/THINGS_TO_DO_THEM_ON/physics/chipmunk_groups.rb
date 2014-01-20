module TextSpace
	module Groups
		# List some available constants for Chipmunk group IDs.
		
		# Unlike layers, groups are just an ID number, NOT a bitvector.
		# Chipmunk just checks to see if the two IDs match.
		# If they match, then the two objects are in the same group.
		
		# Objects in the same group are like parts of a single object:
		# they will NOT collide.
		# This is the opposite of Layers.
		
		# May just want to use object IDS for groups as necessary,
		# as suggested by the Chipmunk documentation.
	end
end