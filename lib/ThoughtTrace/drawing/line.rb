module ThoughtTrace


module Drawing # this module needs a better name
DEFAULT_COLOR = Gosu::Color.argb(0xaaFF0000)

class << self

# draw a line that connects points a and b
# (line will always be drawn from left to right)
def draw_line(render_context, a,b, color:DEFAULT_COLOR, thickness:6, line_offset:0.5, z_index:0)
	# may want to sort the points by x value, in order to help maintain vertex winding
	a,b = [a, b].sort_by{ |v| v.x  }
	
	
	x = b - a
	
	x_hat = x.normalize
	y_hat = x_hat.perp
	
	delta = (thickness.to_f*line_offset)
	
	verts = [
		a + y_hat*delta,
		b + y_hat*delta,
		b - y_hat*delta,
		a - y_hat*delta
	].reverse!
	
	
	render_context.gl z_index do
		GL.Enable(GL::GL_BLEND)
		GL.BlendFunc(GL::GL_SRC_ALPHA, GL::GL_ONE_MINUS_SRC_ALPHA)
		
		# opengl code copied from code used to draw Poly shapes
		GL.Begin(GL::GL_TRIANGLE_FAN)
			GL.Color4ub(color.red, color.green, color.blue, color.alpha)
			
			# TODO: Convert coordinates on GPU using local coordinates and transform
			# transform should account for translation and rotation
			verts.each{ |v| GL.Vertex2f(v.x.round, v.y.round)  }
		
		GL.End()
	end
end

end
end



end