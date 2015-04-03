require 'state_machine'

module ThoughtTrace
	module Constraints
		module Visualizations


class Visualization < ThoughtTrace::ComponentContainer
	def initialize
		super()
		
		@timer = ThoughtTrace::Timer.new
		
		style = ThoughtTrace::Components::Style.new
		add_component style
		
		# create style modes to match state machine states
		@components[:style].mode = :unbound
		@components[:style].mode = :bound
		@components[:style].mode = :active
		
		# set initial style mode
		@components[:style].mode = :unbound
	end
	
	state_machine :state, :initial => :unbound do
		# no constraint targets
		state :unbound do
			def update
				
			end
			
			def draw(a,b,z)
				
			end
		end
		
		# have constraint targets
		state :bound do
			def update
				
			end
			
			def draw(a,b,z)
				
			end
		end
		
		# just applied constraint tick
		state :active do
			def update
				@timer.update
				
				
			end
			
			def draw(a,b,z)
				
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
		@components[:style].mode = :unbound
	end
	
	def activate_bound_style
		@components[:style].mode = :bound
	end
	
	def activate_active_style
		@components[:style].mode = :active
	end
end



end
end
end