module ThoughtTrace
	module Constraints


# Draw a line between two entities, like an edge in a graph
# Line will be updated as the entities move
# This is intended more as a basic test of the Constraint system than anything else
class DrawEdge < Constraint
	# are constraints always pairwise?
	# not sure if I can even make that call right now
	
	
	# bind constraint to entity objects
	def initialize(*args)
		super(*args)
		
		
		# TODO: consider putting the 
		@cascade = ThoughtTrace::Style::Cascade.new
		@cascade.tap do |c|
			c['color'] = Gosu::Color.argb(0xaaFF0000)
		end
	end
	
	
	# apply one tick of the constraint
	def update
		# TODO: properly define Components::Physics#center
		@a = @entities[0][:physics].center
		@b = @entities[1][:physics].center
	end
	
	# visualize the current state of the constraint
	def draw
		ThoughtTrace::Drawing.draw_line($window, @a,@b, color:@cascade['color'], thickness:20)
	end
end



end
end