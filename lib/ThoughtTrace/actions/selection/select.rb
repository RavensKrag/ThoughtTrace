module ThoughtTrace
	module Actions
		module EmptySpace
			module Actions


# Helper Action.
# Performs core of lasso selection, (query - visualize - return set)
# but does not modify the actual selection.
class Select < ThoughtTrace::Actions::BaseAction
	initialize_with :space
	
	
	# called on first tick
	def press(point)
		@verts = [point]
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		dist = 10
		@verts << point if @verts.last.distsq(point) > dist**2
		
		@bb = bb_for_verts(point, @verts)
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		# n/a - selection is always changed on #release
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		# n/a
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		# NOTE: may have to perform multiple queries, because Shape must be a convex whole.
		
		# doesn't really matter what the body is like, only want the Shape
		# body = CP::Body.new(1,1)
		# p CP::Shape::Poly.valid? @verts
		# puts "forward is ok" if CP::Shape::Poly.valid? @verts
		# puts "backward is ok" if CP::Shape::Poly.valid? @verts.reverse
		# shape = CP::Shape::Poly.new body, @verts
		
		set = Set.new
		
		# @space.shape_query shape do |shape, contact_point_set|
		# 	# add items to set, depending on results of query
		# end
		
		# could potentially implement a custom point-in-polygon test,
		# using the center points of the queries in the immediate area.
		# (similar to the general cull-to-get-close approach used in games in general)
		# (and also kinda like single mouse picking? because that uses distance to center as a criterion)
		
		@space.bb_query @bb do |entity|
			p = entity[:physics].center
			if point_in_polygon?(p, @verts)
				set.add entity
			end
		end
		
		puts "#{set.size} items selected"
		
		
		return set
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		# --- draw loop line
		# most edges
		z = 1000
		color = Gosu::Color.argb(0x88FFFFFF)
		weight = 4
		
		@verts.each_cons(2) do |a,b|
			ThoughtTrace::Drawing.draw_line(
				$window,
				a,b,
				color:color, thickness:weight, line_offset:0.5, z_index:z
			)
		end
		
		# final connecting edge ( special case, maybe you want a different style? )
		a = @verts.last
		b = @verts.first
		ThoughtTrace::Drawing.draw_line(
			$window,
			a,b,
			color:color, thickness:weight, line_offset:0.5, z_index:z
		)
		
		
		# --- draw bounding box
		color = Gosu::Color.argb(0x33FFFFFF)
		@bb.draw color, z
		
		
		
		# $window.gl z do
		# 	GL.PushMatrix()
		# 	# GL.Translatef(self.body.p.x, self.body.p.y, 0)
		# 		GL.Begin(GL::GL_TRIANGLE_FAN)
		# 			GL.Color4ub(color.red, color.green, color.blue, color.alpha)
					
					
		# 			# iterations = 60 # seems like high iterations cause crashes?
		# 			# # iterations = 12
					
					
		# 			# rotation_angle = 2*Math::PI / iterations # radians
		# 			# rotation_vector = CP::Vec2.for_angle rotation_angle
					
					
		# 			# vec = CP::Vec2.new(self.radius, 0)
					
		# 			# # center
		# 			# GL.Vertex2f(0, 0)
					
		# 			# # verts on the edge of the circle
		# 			# (iterations+1).times do # extra iteration to loop back to start
		# 			# 	GL.Vertex2f(vec.x, vec.y)
						
		# 			# end
					
					
		# 			@verts.each do |vec|
		# 				GL.Vertex2f(vec.x, vec.y)
		# 			end
		# 		GL.End()
		# 	GL.PopMatrix()
		# end
	end
	
	
	private
	
	def bb_for_verts(point, list)
		x = point.x
		y = point.y
		l, b, r, t = [x,y,x,y]
		list.each do |vert|
			a = vert.x;  l = a if a < l
			a = vert.y;  b = a if a < b
			a = vert.x;  r = a if a > r
			a = vert.y;  t = a if a > t
		end
		
		return CP::BB.new(l,b,r,t)
	end
	
	def point_in_polygon?(point, verts)
		# sources:
		# http://erich.realtimerendering.com/ptinpoly/
		# http://en.wikipedia.org/wiki/Point_in_polygon
		
		
		# don't even bother if the bounding box test fails
		return false unless @bb.contains_vect? point
		
		
		
		crossing_count = 0
		
		# cast a ray going in the +x direction from the point, and count edge crossings
		
		# NOTE: be very careful to NOT change the original verts
		verts = verts.collect{ |v|  v - point }          # all verts relative to the input point
		edges = (verts.each_cons(2).to_a << [verts.last, verts.first])  # collect all edge pairs
		
		edges.each do |a,b|  # The edge of the polygon is formed by the line AB
			# could check for differing sign with (a * b < 0), because 'differing' means it has to be one pos and one negative, which will always be negative
			
			
			# if y components differ in sign
			if a.y > 0 && b.y < 0 or a.y < 0 && b.y > 0
				if a.x > 0 && b.x > 0
					# x components are both positive
					crossing_count += 1 # crossing found
				elsif a.x > 0 && b.x < 0 or a.x < 0 && b.x > 0
					# x components differ in sign
					low, high = [a.x, b.x].sort
					if point.x.between?(low, high)
						# the x component intersects the edge
						crossing_count += 1 # crossing found
					end
				end
			end
		end
		
		if crossing_count % 2 == 0
			# even
			# outside
			return false
		else
			# odd
			# inside
			return true
		end
	end
end



end
end
end
end