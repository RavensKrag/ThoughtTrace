module CP
	module Shape
		class Circle
			def draw(color, z=0)
				$window.gl z do
					glPushMatrix()
					glTranslatef(self.body.p.x, self.body.p.y, 0)
						glBegin(GL_TRIANGLE_FAN)
							glColor4ub(color.red, color.green, color.blue, color.alpha)
							
							
							iterations = 60 # seems like high iterations cause crashes?
							# iterations = 12
							
							
							rotation_angle = 2*Math::PI / iterations # radians
							rotation_vector = CP::Vec2.for_angle rotation_angle
							
							
							vec = CP::Vec2.new(self.radius, 0)
							
							# center
							glVertex2f(0, 0)
							
							# verts on the edge of the circle
							(iterations+1).times do # extra iteration to loop back to start
								glVertex2f(vec.x, vec.y)
								
								vec = vec.rotate rotation_vector
							end
						glEnd()
					glPopMatrix()
				end
			end
			
			def area
				CP.area_for_circle 0, self.radius # inner, outer (order doesn't seem to matter)
			end
		end
	end
end