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
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		# n/a
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
		
		body = CP::Body.new(1,1) # doesn't really matter what the body is like, only want the Shape
		# shape = CP::Shape::Poly.new body, @verts
		
		set = Set.new
		
		# @space.shape_query shape do |shape, contact_point_set|
		# 	# add items to set, depending on results of query
		# end
		
		# could potentially implement a custom point-in-polygon test,
		# using the center points of the queries in the immediate area.
		# (similar to the general cull-to-get-close approach used in games in general)
		# (and also kinda like single mouse picking? because that uses distance to center as a criterion)
		
		
		return set
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
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
		
		a = @verts.last
		b = @verts.first
		ThoughtTrace::Drawing.draw_line(
			$window,
			a,b,
			color:color, thickness:weight, line_offset:0.5, z_index:z
		)
		
		
		
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
end



end
end
end
end