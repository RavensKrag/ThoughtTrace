module TextSpace
	# Draw a line between two points with variable width
	class Line
		# def initialize(a, b)
			# @a = a
			# @b = b
		# end
		
		def update
			
		end
		
		def draw(p0, p1, width, z=0, color=0xffffffff)
			# NOTE: Line represented as quad, but will not always fit tight in a AABB
			
			normal = (p1 - p0).normalize.perp
			
			half_width = width/2
			corners = [
				p0 + normal*half_width,
				p1 + normal*half_width,
				p1 - normal*half_width,
				p1 - normal*half_width,
			]
			
			$window.draw_quad	corners[0].x, corners[0].y, color, 
								corners[1].x, corners[1].y, color, 
								corners[2].x, corners[2].y, color, 
								corners[3].x, corners[3].y, color, 
								z
		end
	end
end