module ThoughtTrace
	module Constraints
		module Visualizations



class DrawEdge < Visualization
	def initialize
		super()
		
		# TODO: consider putting the style at the class-level in a class-instance variable
		@components[:style].edit(:unbound) do |c|
			c['color'] = Gosu::Color.argb(0xaa220000)
		end
		
		@components[:style].edit(:bound) do |c|
			c['color'] = Gosu::Color.argb(0xaaBB0000)
		end
		
		@components[:style].edit(:active) do |c|
			c['color'] = Gosu::Color.argb(0xaaFFAAAA)
		end
	end
	
	def draw(a,b,z)
		color = @components[:style]['color']
		
		ThoughtTrace::Drawing.draw_line(
			$window,
			a[:physics].center, b[:physics].center, 
			color:color, thickness:5, z_index:z
		)
	end
end


end
end
end