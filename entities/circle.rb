require 'state_machine'
require './serialization/serializable'

module TextSpace
	class Circle
		attr_reader :physics
		
		def initialize(radius)
						body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
						shape = CP::Shape::Circle.new body, radius
			@physics = TextSpace::Component::Physics.new(self, body, shape)
			
			@physics.body.p = CP::Vec2.new(0,0)
			
			
			@color = Gosu::Color.argb(0xffff0000)
		end
		
		def update
			
		end
		
		def draw(z_index=0)
			@physics.shape.draw @color, z_index
		end
	end
end