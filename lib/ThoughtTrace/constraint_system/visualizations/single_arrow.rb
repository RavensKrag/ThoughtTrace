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
	
	def draw(a,b)
		color = @style['color']
		weight = 10
		fin_weight = (weight * 0.8).to_i
		
		offset = CP::Vec2.new(-30, 20)
		
		
		
		ac = a[:physics].center
		bc = b[:physics].center
		
		# body line
		ThoughtTrace::Drawing.draw_line(
			$window,
			ac, bc, 
			color:color, thickness:weight
		)
		
		# fins
		x_hat, y_hat = local_vector_basis(a,b)
		
		
		v1 = bc + (x_hat*offset.x) + (y_hat*offset.y)      # up   fin endpoint
		v2 = bc + (x_hat*offset.x) + (y_hat*offset.y * -1) # down fin endpoint
		
		
		ThoughtTrace::Drawing.draw_line(
			$window,
			bc, v1, 
			color:color, thickness:fin_weight
		)
		
		ThoughtTrace::Drawing.draw_line(
			$window,
			bc, v2, 
			color:color, thickness:fin_weight
		)
	end
	
	private
	
	def local_vector_basis(a,b)
		ap = a[:physics].center
		bp = b[:physics].center
		
		x = bp - ap
		
		x_hat = x.normalize
		y_hat = x_hat.perp
		
		return x_hat, y_hat
	end
end


end
end
end