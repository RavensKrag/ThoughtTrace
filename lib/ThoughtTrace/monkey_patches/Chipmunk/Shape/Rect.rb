module CP
	module Shape
		class Rect < Poly
			def initialize(body, width, height, offset=CP::Vec2.new(0,0))
				@width = width
				@height = height
				
				# used to maintain proper offset when you just want to change one dimension
				@offset = offset
				
				
				super(body, new_geometry(width, height), offset)
			end
			
			
			
		# verts named in "x+ right, y+ up" coordinate space
		[:top_left, :top_right, :bottom_right, :bottom_left].each_with_index do |corner, i|
			define_method "#{corner}_vert" do
				self.vert(i)
			end
		end
			
			
			# returns the center of this shape, in local space
			def center
				top_right_vert / 2
			end
			
			
			
			
			# TODO: Make sure @offset is ok this way. It may have to become a relative offset system to get things to resize dynamically as intended. (related to the anchor point system used in Rectangle entity [rectangle anchor]). Come back and check on this when Constraints are more developed. May not work as intended.
			
			def width
				(self.top_right_vert- self.bottom_left_vert).x
			end
			
			def height
				(self.top_right_vert- self.bottom_left_vert).y
			end
			
			def resize!(width, height, offset=nil)
				@offset = offset unless offset.nil?
				
				new_verts = new_geometry(width, height)
				
				self.set_verts! new_verts, @offset
			end
			
			
			
			private
			
			def update_geometry(offset=CP::Vec2.new(0,0))
				new_verts = new_geometry(@width, @height)
				
				self.set_verts! new_verts, offset
			end
			
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