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
			
			c['color_unbound'] = Gosu::Color.argb(0xaa220000)
			c['color_bound']   = Gosu::Color.argb(0xaaBB0000)
			c['color_active']  = Gosu::Color.argb(0xaaFFAAAA)
		end
	end
	
	# TODO: consider having two separate objects for active and inactive states, so that the two states can keep their data completely separate
	# TODO: consider that only one visualization object needs to be made - this wrapper - and that the inside classes could be something else? or maybe that those objects should be the visualization classes, and this wrapper should be called something else
	
	
	state_machine :state do
		# no constraint targets
		state :unbound do
			def update
				
			end
			
			def draw(a,b)
				color = @cascade['color_unbound']
				
				ThoughtTrace::Drawing.draw_line(
					$window,
					a[:physics].center, b[:physics].center, 
					color:color, thickness:5
				)
			end
		end
		
		# have constraint targets
		state :bound do
			def update
				
			end
			
			def draw(a,b)
				color = @cascade['color_bound']
				
				ThoughtTrace::Drawing.draw_line(
					$window,
					a[:physics].center, b[:physics].center, 
					color:color, thickness:5
				)
			end
		end
		
		# just applied constraint tick
		state :active do
			def update
				@timer.update
			end
			
			def draw(a,b)
				# TODO: properly define Components::Physics#center
				color = @cascade['color_active']
				
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
end
end