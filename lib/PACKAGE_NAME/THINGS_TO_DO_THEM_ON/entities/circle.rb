require 'state_machine'

require File.expand_path '../../../utilities/serialization/serializable', __FILE__

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
		
		
		
		
		def click
			
		end
		
		def release
			
		end
		
		
		
		
		
		def mouse_over
			
		end
		
		def mouse_out
			
		end
		
		
		
		
		
		
		include TextSpace::Serializable
		
		def init_with coder
			data = YAML.load(coder.scalar)
			
			x,y,r = data.split(",").collect{|i| i.to_f }
			
			initialize(r)
			
			@physics.body.p = CP::Vec2.new(x,y)
		end

		def to_string_representation
			"#{@physics.body.p.x},#{@physics.body.p.y},#{@physics.shape.radius}"
		end
		
		class << self
			def from_string_representation(string_representation)
				data = YAML.load(string_representation)
				x,y,r = data.split(",").collect{|i| i.to_f }
				
				obj = self.new(r)
				
				obj.physics.body.p = CP::Vec2.new(x,y)
			end
		end
	end
end