module ThoughtTrace
	module Constraints
		module Visualizations



class DrawEdge < Visualization
	def initialize
		super()
		
		# TODO: consider putting the cascade at the class-level in a class-instance variable
		@cascade = ThoughtTrace::Style::Cascade.new
		@cascade.tap do |c|
			c['color'] = Gosu::Color.argb(0xaaFF0000)
		end
	end
	
	# TODO: consider having two separate objects for active and inactive states, so that the two states can keep their data completely separate
	# TODO: consider that only one visualization object needs to be made - this wrapper - and that the inside classes could be something else? or maybe that those objects should be the visualization classes, and this wrapper should be called something else
	def update_active
		
	end
	
	def update_inactive
		
	end
	
	def draw_active(a,b)
		# TODO: properly define Components::Physics#center
		
		ThoughtTrace::Drawing.draw_line(
			$window,
			a[:physics].center, b[:physics].center, 
			color:@cascade['color'], thickness:5
		)
	end
	
	def draw_inactive(a,b)
		draw_active(a,b)
	end
end


end
end
end