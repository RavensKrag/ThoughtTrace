require 'state_machine'

module ThoughtTrace
	module Constraints


class Visualization
	def initialize
		super()
		
		@timer = ThoughtTrace::Timer.new
	end
	
	state_machine :state, :initial => :unbound do
		# no constraint targets
		state :unbound do
			def update
				
			end
			
			def draw(a,b)
				
			end
		end
		
		# have constraint targets
		state :bound do
			def update
				
			end
			
			def draw(a,b)
				
			end
		end
		
		# just applied constraint tick
		state :active do
			def update
				@timer.update
				
				
			end
			
			def draw(a,b)
				
			end
		end
		
		
		event :bind do
			transition :unbound => :bound
		end
		
		event :unbind do
			transition any => :unbound
		end
		
		event :activate do
			transition :bound => :active
		end
		
		event :rest do
			transition :active => :bound
		end
		
		
		before_transition  :bound => :active, :do => :activation_callback
	end
	
	
	def activation_callback
		puts "start"
		# time to wait, in ms
		@timer.wait(800) do
			self.rest
		end
	end
end



end
end