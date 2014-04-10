module ThoughtTrace
	module Components


class Style < Component
	interface_name :style
	
	attr_accessor :name, :parent_style
	
	def initialize(name, parent_style=nil)
		@name = name
		
		# should have various properties
		# properties can cascade off another style component, like in CSS
		@parent_style = parent_style
		
		
		# Want to write properties in such a way that you
		# get the same word used in a lot of different contexts
		# that way colors etc can get thrown around more easily.
		# ex) the color of one block of text could be the the color of some other element
		# @properties = [
		# 	:height, # font height and rectangle height.  Text is a separate object anyhow.
		# 	:color, # if you want to color the bg, you should be coloring a separate element
		# ]
		
		@mode = :default
		
		# {:mode_name => {:property_name => value} }
		# ex) @properties[:default][:color]
		@properties = {@mode => Hash.new}
	end
	
	def update
		
	end
	
	def draw(z=0)
		
	end
	
	
	
	
	def mode=(new_mode)
		@properties[new_mode] ||= Hash.new
		
		@mode = new_mode
	end
	
	def mode
		return @mode
	end
	
	
	# Request the value of a certain property
	# Will cascade into parent properties as necessary
	# (search through parent styles until you find a usable value)
	def [](property)
		foo = @properties[@mode][property]
		
		if foo.nil?
			warn "Warning: Property :#{property} not defined for :#{@mode} mode of style #{@name}"
			
			if @parent_style
				# Delegate up the cascade chain, trying to find a usable value
				foo = @parent_style[property]
			else
				# Bottom of the chain
				# TOOD: Figure out a way to give a sense of the chain where the property was not found. Maybe that information is in the backtrace already?
				# Would be easier to return proper debug information at the top of the chain. Then you could alert where the property was requested.
				raise "ERROR: Style property #{property} not defined"
			end
		end
		
		
		return foo
	end
	
	# Set property
	# Will only ever set the value at this level
	def []=(property, value)
		@properties[@mode][property] = value
	end
	
	# Edit one style mode (not necessarily the active mode)
	# Protects against forgetting to switch back after temporarily switching modes to make an edit
	def edit(mode=@mode)
		# want to use the methods to get / set mode, rather than instance variables
		# kinda weird relative to standard ruby style, but it needs to happen
		# so that the hashes can be initialized correctly,
		# without having to repeat the init code all over the place
		old_mode = self.mode
			self.mode = mode
			
			self.tap do |mode_handle|
				yield mode_handle
			end
		self.mode = old_mode
	end
end



end
end