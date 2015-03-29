require 'state_machine'

module ThoughtTrace
	module Constraints
		module Visualizations


class Visualization
	def initialize
		super()
		
		@timer = ThoughtTrace::Timer.new
		
		@style = ThoughtTrace::Components::Style.new
		
		# create style modes to match state machine states
		@style.mode = :unbound
		@style.mode = :bound
		@style.mode = :active
		
		# set initial style mode
		@style.mode = :unbound
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
		
		
		after_transition  any => :unbound, :do => :activate_unbound_style
		after_transition  any => :bound,   :do => :activate_bound_style
		after_transition  any => :active,  :do => :activate_active_style
	end
	
	
	def activation_callback
		puts "start"
		# time to wait, in ms
		@timer.wait(800) do
			self.rest
		end
	end
	
	def activate_unbound_style
		@style.mode = :unbound
	end
	
	def activate_bound_style
		@style.mode = :bound
	end
	
	def activate_active_style
		@style.mode = :active
	end
end



end
end
end