module CP
	module Shape
		class Poly
			# draw quad from verts in world space coordinates
			def draw(color, z=0)
				raise "Can only draw quads" unless self.num_verts == 4
				
				
				verts = Array.new
				self.each_vert do |v|
					vec = self.body.local2world(v)
					
					verts.push vec.x, vec.y, color
				end
				
				
				$window.draw_quad *verts, z
			end
			
			# return an array of all vertices
			def verts
				out = Array.new(self.num_verts)
				self.num_verts.times do |i|
					out[i] = self.vert(i)
				end
				
				return out
			end
			
			def area
				CP.area_for_poly self.verts
			end
			
			
			
			include Enumerable
			
			def each
				self.num_verts.times do |i|
					yield self.vert(i)
				end
			end
			
			alias :each_vert :each
			alias :each_vert_with_index :each_with_index
			alias :each_vert_with_object :each_with_object
		end
	end
end