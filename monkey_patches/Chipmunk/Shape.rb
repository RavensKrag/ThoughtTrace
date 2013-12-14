module CP
	module Shape
		class Poly
			# draw quad from verts in world space coordinates
			def draw(color, z=0)
				raise "Can only draw quads" unless self.num_verts == 4
				
				
				verts = Array.new
				self.num_verts.times do |i|
					# i = self.num_verts-1 - i # reverse winding, if necessary
					
					vec = self.body.local2world(self.vert(i))
					
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
		end
	end
end