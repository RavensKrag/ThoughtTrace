module ThoughtTrace
	module Components


class Style < Component
	interface_name :style
	
	attr_accessor :parent_style
	
	def initialize(parent_style=nil)
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
		
		@properties = Hash.new
	end
	
	def update
		
	end
	
	def draw(z=0)
		
	end
	
	# Request the value of a certain property
	# Will cascade into parent properties as necessary
	# (search through parent styles until you find a usable value)
	def [](property)
		foo = @properties[property]
		
		if foo.nil?
			if @parent_style
				# Delegate up the cascade chain, trying to find a usable value
				foo = @parent_style[property]
			else
				# Bottom of the chain
				# TOOD: Figure out a way to give a sense of the chain where the property was not found. Maybe that information is in the backtrace already?
				raise "Style property #{property} not defined"
			end
		end
		
		
		return foo
	end
	
	# Set property
	# Will only ever set the value at this level
	def []=(property, value)
		@properties[property] = value
	end
end



end
end