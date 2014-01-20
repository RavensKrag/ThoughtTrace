require 'state_machine'

module TextSpace
	# Connect two points in space with a line
	class Line
		attr_accessor :p1, :p2
		
		attr_reader :physics
		
		def initialize(p1, p2, width=10)
			@p1 = p1
			@p2 = p2
			
			@width = width
			
			
			# Physics component of line has origin on p1, and extends towards p2
						body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
						shape = CP::Shape::Poly.new body, new_geometry(), CP::Vec2.new(0,0)
			@physics = TextSpace::Component::Physics.new(self, body, shape)
			
			@physics.body.p = @p1
			@physics.body.a = CP::Vec2.angle_between(@p1, @p2)
			
			
			# Should be able to move either of the two endpoints of the line
			# To do this, you need to attach shapes to either end
			
			# radius = 10 # radius for mouse detection, not any graphical property
			# @physics = Physics.new @p1, @p2, radius
			
			@color = Gosu::Color.argb(0xffffffff)
		end
		
		def update
			
		end
		
		def draw(z_index=0)
			@physics.shape.draw @color, z_index
		end
		
		
		
		
		def recompute_geometry
			# stretch the right end of the geometry to meet the required distance
			p1 = @p1
			p2 = @p2
			
			distance = p1.dist p2
			
			
			verts = Array.new(4)
			@physics.shape.each_vert_with_index do |vert, i|
				if i == 1 || i == 2 # verts for right edge
					vert.x = distance
				end
				
				verts[i] = vert
			end
			
			@physics.shape.set_verts! verts
		end
		
		def new_geometry
			# declare verts with a clockwise winding
			p1 = @p1
			p2 = @p2
			
			
			
			length = p1.dist p2
			displacement = CP::Vec2.new(length, 0)
			
			
			half_width = @width.to_f / 2
			normal = CP::Vec2.new(0,1)
			half_width_along_normal = normal * half_width
			
			
			origin = CP::Vec2.new(0,0)
			
			verts = [
				origin + half_width_along_normal,
				origin + half_width_along_normal + displacement,
				origin - half_width_along_normal + displacement,
				origin - half_width_along_normal,
			]
			
			
			
			
			raise "Problem with specified verts." unless CP::Shape::Poly.valid? verts
			
			return verts
		end
	end
end