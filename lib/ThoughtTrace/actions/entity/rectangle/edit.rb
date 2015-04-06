module ThoughtTrace
	class Rectangle
		module Actions


# Change dimensions of Rectangle by moving verts around.
# No aspect ratio locking.
class Edit < ThoughtTrace::Actions::BaseAction
	MARGIN = 20
	MINIMUM_DIMENSION = 10
	
	initialize_with :entity
	
	# called on first tick
	def press(point)
		# mark the initial point for reference
		@origin = point
		
		# test in which region of the shape the point lies
		# ASSUMPTION: point is already known to lie within the shape
		
		
		
		@original_verts = @entity[:physics].shape.verts
		
		# origin top left, x+ right, y+ down,
		# assuming one of the verts is on the origin, and shape stretches in the positive direction
		# (standard structure of Rect shape)
		@original_width  = @entity[:physics].shape.width
		@original_height = @entity[:physics].shape.height
		
		
		local_point = @entity[:physics].body.world2local point
		m = MARGIN
		w = @original_width
		h = @original_height
		
		# xL = 0
		xa = m
		xb = w-m
		xR = w
		
		# yT = 0
		ya = m
		yb = h-m
		yB = h
		
		
		x = 
			if    local_point.x < xa
				# left
				-1
			elsif local_point.x < xb
				# center
				0
			elsif local_point.x < xR
				# right
				puts "right"
				1
			end
		
		y = 
			if    local_point.y < ya
				# top
				puts "top"
				-1
			elsif local_point.y < yb
				# center
				0
			elsif local_point.y < yB
				# bottom
				1
			end
		
		# different edge characteristics,
		# slicing from low to high vs chopping the edges from the core
		# only would really effect very small parts of the data, but it's something to think about
		
		
		@direction = CP::Vec2.new(x,y)
		
		
		# verts are specified [tl, tr, br, bl] in +x right y+ up space
		# (not sure about that coordinate space... seems to working just fine here)
		
		
		
		# wait this is too general of a solution.
		# the moving of the edge allows for the creation of shapes which are no longer rectangles.
		# That is not what you want.
		# You need to enforce that edges can only move along one axis,
		# while verts can move on two axes.
		
		# @direction.normalize!
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		displacement = point - @origin
		
		x = @direction.x
		y = @direction.y
		
		@new_verts = nil
		
		@width, @height =
			if x != 0 and y != 0
				# corner
				
				# === get corner index
				i = 
					if    x == -1 and y == -1
						# top left
						puts "top left"
						3 # xy (prev vert axis, next vert axis)
					elsif x ==  1 and y == -1
						# top right
						puts "top right"
						2 # yx
					elsif x == -1 and y ==  1
						# bottom left
						puts "bottom left"
						0 # yx
					elsif x ==  1 and y ==  1
						# bottom right
						puts "bottom right"
						1 # xy
					else
						raise "derp. this should not happen EVER."
					end
				
				
				# === move the corner and the two adjacent verts to preserve rectangle
				# (adjacency in a ring)
				verts = @original_verts.collect{|x| x.clone}
				
				max_i = verts.size-1
				prev_i = (i == 0     ? max_i : i-1)
				next_i = (i == max_i ? 0     : i+1)
				
				before  = verts[prev_i]
				current = verts[i]
				after   = verts[next_i]
				
				
				
				# alter vectors in-place
				current.x += displacement.x
				current.y += displacement.y
				
				
				if i % 2 == 0
					# even
					# xy
					before.x, after.y = current.to_a
				else
					# odd
					# yx
					after.x, before.y = current.to_a
				end
				
				# === offset all vectors to give verts the same form as a default Rect shape
				# offset = CP::Vec2.new(verts[1].x, verts[3].y)
				# offset = (verts[1] - verts[3])
				# offset = (verts[3] - verts[1])
				offset = verts.last.clone
					p @original_verts.collect{|p| p.to_s}
					p verts.collect{|p| p.to_s}
					puts offset
				verts.each{ |p| p.x -= offset.x; p.y -= offset.y  }
					p verts.collect{|p| p.to_s}
				@new_verts = verts
				
				[@original_width, @original_height]
			elsif x == 0 and y == 0
				# center
				[@original_width, @original_height]
			else
				# edge
				[@original_width+displacement.x*x, @original_height+displacement.y*y]
			end
		
		@width  = @original_width+displacement.x*x
		@height = @original_height+displacement.y*y
		@anchor = anchor_point()
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		if @new_verts
			width,height = @entity[:physics].shape.top_right_vert.to_a
			
			
			
			offset = CP::Vec2.new(0,0)
			@entity[:physics].shape.set_verts! @new_verts, offset
			
			
			
			
			# counter-steering
			# use the current set height and width, NOT the original height and width. not the same
			# delta_width  = width  - @entity[:physics].shape.width
			# delta_height = height - @entity[:physics].shape.height
			
			@entity[:physics].shape.instance_eval do
				@width  = width
				@height = height
			end
			
			# @entity[:physics].body.p.x -= delta_width * @anchor.x
			# @entity[:physics].body.p.y -= delta_height * @anchor.y
		else
			@entity.resize!(@width, @height, @anchor)
		end
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@entity.resize!(@original_width, @original_height, @anchor)
		# use the same anchor from the apply step.
		# this should be enough to reverse the operation.
		# There's no real way to calculate an "inverse anchor",
		# but I don't think that's necessary anyway.
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		# TODO: draw margins to get a better idea of how they should be altered as the shape changes.
		# TODO: consider implementing margin rendering using entities and constraints. Then that data could easily be used to drive the modulation of the margins themselves.
	end
	
	
	
	
	
	
	private
	
	def anchor_point
		# normalized anchor
		# NOTE: remember that the anchor specifies the amount of counter-steering
		# TODO: allow for more analog anchor specification
		# TODO: consider anchoring based on where the initial point of context was.
		# TODO: consider more complex margin specification. Maybe it should be proportional to size? Not sure in what specify way though.
		
		
		x = 
			if @direction.x > 0
				# pos
				0.0
			elsif @direction.x < 0
				# neg
				1.0
			else
				# zero
				# center
				0.5
			end
		y = 
			if @direction.y > 0
				# pos
				0.0
			elsif @direction.y < 0
				# neg
				1.0
			else
				# zero
				0.5
			end
		
		
		return CP::Vec2.new(x,y)
	end
end



end
end
end