module TextSpace
	module Component
		# Manage elements of style, such as font face, or colors.
		# One Style object can have multiple style modes, with different property values.
		# (Similar to a CSS stylesheet)
		class Style
			def initialize
				super() # set up state machine
				
				@properties = Hash.new
				
				@properties.each do |key, value|
					
				end
			end
			
			PROPERTIES = [
				:height,
				:active_color, :default_color, :color,
				:box_visible, :box_color
			]
			
			
			
			
			PROPERTIES.each do |property|
				# Similar to attr_accessor, but accesses values through a hash
				attr_accessor property
			end
			# PROPERTIES.each &:attr_accessor # might not work like this?
			
			
			def self.metaclass; class << self; self; end; end
			
			class << self
				
			end
			
			
			
			def copy_style_from(other)
				# TODO: consolidate style values into one object / hash for easy copying
				PROPERTIES.each do |property|
					self.send "#{property}=", other.send(property)
				end
			end
			
			
			state_machine :style, :initial => :default do
				state :default do
					
				end
				
				state :active do
					
				end
				
				state :hover do
					
				end
				
				
				after_transition any => :default, :do => :apply_default_style
				after_transition any => :active, :do => :apply_active_style
				after_transition any => :hover, :do => :apply_hover_style
				
				
				
				event :enable_hover do
					transition any - :active => :hover
				end
				
				event :remove_hover do
					transition :hover => :default
				end
				
				event :enable_active do
					transition any => :active
				end
				
				event :remove_active do
					transition :active => :default
				end
			end
		end
		
		# Defines all the default style properties, and their default values
		class DefaultRootStyle < Style
			def initialize
				super()
				
				
				# @height = 
				# @active_color = 
				# @default_color = 
				# @color = 
				
				# @box_visible = 
				# @box_color = 
			end
		end
	end
end
