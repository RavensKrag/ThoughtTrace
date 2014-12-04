module ThoughtTrace
	module Constraints
		module Visualizations



class SingleArrow < Visualization
	def initialize
		super()
	end
	
	# TODO: consider having two separate objects for active and inactive states, so that the two states can keep their data completely separate
	# TODO: consider that only one visualization object needs to be made - this wrapper - and that the inside classes could be something else? or maybe that those objects should be the visualization classes, and this wrapper should be called something else
	def update_active(a,b)
		
	end
	
	def update_inactive(a,b)
		
	end
	
	def draw_active(a,b)
		
	end
	
	def draw_inactive(a,b)
		
	end
end


end
end
end