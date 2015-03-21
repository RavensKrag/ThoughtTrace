module CP
	module Shape
		class Circle
			def draw(color, z=0)
				$window.gl z do
					GL.PushMatrix()
					# TODO: consider using integer transforms
					GL.Translatef(self.body.p.x, self.body.p.y, 0)
						GL.Begin(GL::GL_TRIANGLE_FAN)
							GL.Color4ub(color.red, color.green, color.blue, color.alpha)
							
							
							# iterations = 60 # seems like high iterations cause crashes?
							# # iterations = 12
							
							
							# rotation_angle = 2*Math::PI / iterations # radians
							# rotation_vector = CP::Vec2.for_angle rotation_angle
							
							
							# vec = CP::Vec2.new(self.radius, 0)
							
							# # center
							# GL.Vertex2f(0, 0)
							
							# # verts on the edge of the circle
							# (iterations+1).times do # extra iteration to loop back to start
							# 	GL.Vertex2f(vec.x, vec.y)
								
							# 	vec = vec.rotate rotation_vector
							# end
							
							
							debug_print = ->(list){
								puts "---"
								puts list.collect{ |p| p.to_s  }
							}
							step = 1
							
							
							
							q_half = Array.new
								x = self.r
								y = 0
								r2 = self.r**2
								
								loop do
									x -= step if ((x**2) + (y**2)) > r2
									y += step
									
									q_half << CP::Vec2.new(x, y) unless y >= x
									
									break if y >= x
								end
							# debug_print[q_half]
							
							
							q1     = q_half + q_half.collect{ |p|  CP::Vec2.new(p.y, p.x) }.reverse
							
							q12    = q1 + q1.collect{ |p|  CP::Vec2.new(-p.x, p.y) }.reverse
								# q12.sort_by!{|p| -p.x } # go from right to left
								
							q1234  = q12 + q12.collect{ |p|  CP::Vec2.new(p.x, -p.y) }.reverse
								debug_print[q1234]
							
							
							GL.Vertex2f(0, 0)
							q1234.each do |vec|
								GL.Vertex2f(vec.x.round, vec.y.round)
							end
							vec = q1234.first
							GL.Vertex2f(vec.x.round, vec.y.round)
						GL.End()
					GL.PopMatrix()
				end
			end
			
			def area
				CP.area_for_circle 0, self.radius # inner, outer (order doesn't seem to matter)
			end
			
			
			# return center of this shape in local space
			def center
				# NOTE: I'm not totally sure that this will work in general, because of the shape offset. However, it should work fine within the system defined by ThoughtTrace
				CP::Vec2.new(0,0)
			end
		end
	end
end