module CP
	module Shape
		class Rect < Poly
			def initialize(body, width, height, offset=CP::Vec2.new(0,0))
				
				super(body, new_geometry(width, height), offset)
			end
			
		[:top_left, :top_right, :bottom_right, :bottom_left].each_with_index do |corner, i|
			define_method "#{corner}_vert" do
				self.vert(i)
			end
		end
		
			
			private
			
			def new_geometry(width, height)
				l = 0
				b = 0
				r = width
				t = height
				
				# cw winding
				verts = [
					CP::Vec2.new(l, t),
					CP::Vec2.new(r, t),
					CP::Vec2.new(r, b),
					CP::Vec2.new(l, b)
				]
				
				# raise "Problem with specified verts." unless CP::Shape::Poly.valid? verts
				
				return verts
			end
		end
	end
end