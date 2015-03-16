module ThoughtTrace
	module Constraints
		module Visualizations



class SingleArrow < Visualization
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
		weight = 10
		
		offset = CP::Vec2.new(-30, 20)
		
		
		# body line
		ThoughtTrace::Drawing.draw_line(
			$window,
			a[:physics].center, b[:physics].center, 
			color:color, thickness:weight
		)
		
		# fins
		ap = a[:physics].center
		bp = b[:physics].center
		
		x = bp - ap
		
		x_hat = x.normalize
		y_hat = x_hat.perp
		
		
		v1 = b[:physics].center + (x_hat*offset.x) + (y_hat*offset.y)      # up   fin endpoint
		v2 = b[:physics].center + (x_hat*offset.x) + (y_hat*offset.y * -1) # down fin endpoint
		
		
		ThoughtTrace::Drawing.draw_line(
			$window,
			b[:physics].center, v1, 
			color:color, thickness:weight
		)
		
		ThoughtTrace::Drawing.draw_line(
			$window,
			b[:physics].center, v2, 
			color:color, thickness:weight
		)
	end
end


end
end
end