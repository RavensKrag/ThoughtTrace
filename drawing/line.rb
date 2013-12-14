module TextSpace
	# Draw a line between two points with variable width
	class Line
		attr_accessor :width, :z, :color
		
		def initialize(width, color=0xffffffff)
			@width = width
			
			@color = color
		end
		
		def update
			
		end
		
		def draw(p0, p1, z=0)
			# NOTE: Line represented as quad, but will not always fit tight in a AABB
			
			normal = (p1 - p0).normalize.perp
			
			half_width = @width/2
			corners = [
				p0 + normal*half_width,
				p1 + normal*half_width,
				p0 - normal*half_width,
				p1 - normal*half_width,
			]
			
			$window.draw_quad	corners[0].x, corners[0].y, @color, 
								corners[1].x, corners[1].y, @color, 
								corners[2].x, corners[2].y, @color, 
								corners[3].x, corners[3].y, @color, 
								z
		end
	end
end