module TextSpace
	module Component
		# Dictate basic behavior of all objects which inhabit the Space
		class Physics
			attr_reader :shape
			# attr_reader :body # defined explicitly inside of the :lock state machine
			
			# NOTE: This will probably get weird if and when non-polygonal shapes are allowed.
			def initialize(parent, body, shape)
				super() # Set up state machine
				
				@body = body
				@shape = shape
				@shape.obj = parent
			end
			
			def update
				
			end
			
			# Render collision geometry
			def draw(color, z=0)
				@shape.draw color, z
			end
			
			
			
			# If locked, the position of this object should not be adjusted. Togglable at runtime.
			# This lock currently restricts read/write on any properties of the body.
			# this doesn't work.  you need to be able to read a locked object properties.
			# ex) want to place an object relative to one that is locked down
			# may also interfere with queries, which would be pretty bad
			
			# TODO: Consider moving this into Body instead of having it out here.
			state_machine :body_lock, :initial => :unlocked do
				state :unlocked do
					# delegate body properties to body
					def body
						@body
					end
				end
				
				state :locked do
					# stub delegations to body
					# alternatively: raise warnings or exceptions when trying to access body or it's properties
					def body
						# Multiplicative identity for both mass and moment
						# should function as a null object
						# CP::Body.new(1,1)
						
						# Clone the body, resulting in a read-only copy of values
						# Values can still be set, but the changes will not stick
						@body.clone
					end
				end
				
				
				
				event :lock do
					transition :unlocked => :locked
				end
					after_transition :unlocked => :locked, :do => :lock_transition
				
				
				event :unlock do
					transition :locked => :unlocked
				end
					after_transition :locked => :unlocked, :do => :unlock_transition
			end
			
			
			private
			
			def lock_transition
				# actions.grep(/reset/).each{ |method| @body.send method }
				@body.reset_forces
				
				# need to reset angular and linear velocity as well
				@body.v = CP::Vec2.new(0,0)
				@body.w = 0
			end
			
			def unlock_transition
				
			end
			
			
			
			
			
			
			# Might not need this crazy reflection junk after all
			# but keep it here a bit longer
			def setup_body_delegation
				methods = body_methods()
				
				
			end
			
			
			
			def body_methods
				b_methods = (CP::Body.new(1,1).methods - 1.methods)
				
				setters = b_methods.grep(/.*=/)
				getters = b_methods.select{ |m| setters.include? "#{m}=".to_sym }
				
				# NOTE: Super vulnerable to API changes, but not sure what else to do.
				dependent_properties = (b_methods - setters - getters).shift 4
				
				
				actions = (b_methods - setters - getters - dependent_properties)
				coordinate_space_conversions = actions.grep /.*2.*/
				
				
				data = Struct.new(
					:setters, :getters,
					:dependent_properties,
					
					:actions,
					:coordinate_space_conversions
				)
				
				return data.new(
							setters, getters, 
							dependent_properties, actions, coordinate_space_conversions
						)
			end
		end
	end
end