require 'state_machine'
require './serialization/serializable'

module TextSpace
	# Connect two points in space with a line
	class Line
		attr_accessor :p0, :p1
		
		def initialize(p0, p1, width=10)
			@p0 = p0
			@p1 = p1
			
			@width = width
			
			@line = TextSpace::Drawing::Line.new @width
		end
		
		def update
			
		end
		
		def draw(z_index=0)
			@line.draw @p0, @p1, z_index
		end
	end
end