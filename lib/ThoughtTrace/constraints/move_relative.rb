module ThoughtTrace
	module Constraints


# Track two Entities
# if either one moves,
# move the other one by the same amount

# is there a potential issue of priority?
# will one always be master, and the other slave?
class MoveRelative < Constraint
	def initialize(a, b)
		super()
		
		@a = a
		@b = b
		
		save_last_known_positions
	end
	
	def update
		# should be two mirrored halves
		# figure out how to consolidate
		
		# figure out which of the two has moved,
		# and move the other one by the same amount
		if @a_pos != @a[:physics].body.p
			delta = @a[:physics].body.p = @a_pos
			
			@b[:physics].body.p += delta
		elsif @b_pos != @b[:physics].body.p
			delta = @b[:physics].body.p = @b_pos
			
			@a[:physics].body.p += delta
		end
		
		
		save_last_known_positions
	end
	
	
	private
	
	def save_last_known_positions
		# track last known position for next frame
		@a_pos = @a[:physics].body.p.clone
		@b_pos = @b[:physics].body.p.clone
	end
end



end
end