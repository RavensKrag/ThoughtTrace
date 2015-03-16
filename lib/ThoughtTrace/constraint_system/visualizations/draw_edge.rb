module ThoughtTrace
	module Constraints
		module Visualizations



class DrawEdge < Visualization
	def initialize
		super()
		
		# TODO: consider putting the style at the class-level in a class-instance variable
		@style.edit(:unbound) do |c|
			c['color'] = Gosu::Color.argb(0xaa220000)
		end
		
		@style.edit(:bound) do |c|
			c['color'] = Gosu::Color.argb(0xaaBB0000)
		end
		
		@style.edit(:active) do |c|
			c['color'] = Gosu::Color.argb(0xaaFFAAAA)
		end
	end
	
	# TODO: consider having two separate objects for active and inactive states, so that the two states can keep their data completely separate
	# TODO: consider that only one visualization object needs to be made - this wrapper - and that the inside classes could be something else? or maybe that those objects should be the visualization classes, and this wrapper should be called something else
	def draw(a,b)
		color = @style['color']
		
		ThoughtTrace::Drawing.draw_line(
			$window,
			a[:physics].center, b[:physics].center, 
			color:color, thickness:5
		)
	end
end


end
end
end