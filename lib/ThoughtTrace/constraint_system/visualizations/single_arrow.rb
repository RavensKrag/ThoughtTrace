module ThoughtTrace
	module Constraints
		module Visualizations



class SingleArrow < Visualization
	def self.root_style
		unless @style
			@style = ThoughtTrace::Components::Style.new
			
			# TODO: load the default style info from a project config file
			@style.edit(:unbound) do |c|
				c['color'] = Gosu::Color.argb(0xaa220000)
				c['body_weight'] = 6 # default: 10 (base offset based on the default)
				c['fin_weight']  = (c['body_weight'] * 0.8).to_i
				c['fin_offset']  = CP::Vec2.new(-30, 20)*0.8
			end
			
			@style.edit(:bound) do |c|
				c['color'] = Gosu::Color.argb(0xaaBB0000)
				c['body_weight'] = 6
				c['fin_weight']  = (c['body_weight'] * 0.8).to_i
				c['fin_offset']  = CP::Vec2.new(-30, 20)*0.8
			end
			
			@style.edit(:active) do |c|
				c['color'] = Gosu::Color.argb(0xaaFFAAAA)
				c['body_weight'] = 6
				c['fin_weight']  = (c['body_weight'] * 1).to_i
				c['fin_offset']  = CP::Vec2.new(-30, 12)*0.8
			end
		end
		
		return @style
	end
	
	def initialize
		super()
		
		root_style = self.class.root_style()
		
		# TODO: check cascade order. I think it may have to be inverted or something.
		# (may have to do a weird '0 is high, as an exception' structure)
		# (kinda like how aces are high in some card games, but sometimes they're only 1 (lowest))
			# I want there to be a particular slot that always has priority over other things,
			# which is useful for debugging or whatever,
			# but then I want StyleObjects that are slotted later to have priority over ones that were slotted earlier
			# 
			# NOTE: may also not want to let the user specify what socket to put the new style into, just put it in the next available socket? idk, need UI before I can tell if that's acceptable or not.
		
		
		# TODO: consider putting the style at the class-level in a class-instance variable
		@components[:style].edit(:unbound) do |c|
			c.socket(1, root_style.cascade(:unbound).read_socket(0))
		end
		
		@components[:style].edit(:bound) do |c|
			c.socket(1, root_style.cascade(:bound).read_socket(0))
		end
		
		@components[:style].edit(:active) do |c|
			c.socket(1, root_style.cascade(:active).read_socket(0))
		end
	end
	
	def draw(a,b)
		color       = @components[:style]['color']
		body_weight = @components[:style]['body_weight']
		fin_weight  = @components[:style]['fin_weight']
		
		offset      = @components[:style]['fin_offset']
		# offset of the 'up' fin in coordinates local to the line from A to B
		
		
		
		ac = a[:physics].center
		bc = b[:physics].center
		
		# body line
		ThoughtTrace::Drawing.draw_line(
			$window,
			ac, bc, 
			color:color, thickness:body_weight
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