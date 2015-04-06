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
		# bl,br,tr,tl @entity[:physics].shape.verts
		
		# bitmask for what verts should be changed
		@vert_bitmask = 
			case [x,y]
				when [-1, -1]
					0b1000 # top left vert
				when [ 0, -1]
					0b1100 # top edge
				when [ 1, -1]
					0b0100 # top right vert
				
				when [-1,  0]
					0b1001 # left edge
				when [ 0,  0]
					0b0000 # center
				when [ 1,  0]
					0b0110 # right edge
				
				when [-1,  1]
					0b0001 # bottom left vert
				when [ 0,  1]
					0b0011 # bottom edge
				when [ 1,  1]
					0b0010 # bottom right vert
			end
		# wait this is too general of a solution.
		# the moving of the edge allows for the creation of shapes which are no longer rectangles.
		# That is not what you want.
		# You need to enforce that edges can only move along one axis,
		# while verts can move on two axes.
		
		@direction.normalize!
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		displacement = point - @origin
		
		# projection = displacement.project(@direction)
		
		
		
		if    [0b1001, 0b0110].include? @vert_bitmask
			# x axis only (left or right edge)
			displacement.y = 0
		elsif [0b0011, 0b1100].include? @vert_bitmask
			# y axis only (top or bottom edge)
			displacement.x = 0
		else
			# movement on both axes
			# single vert
			
		end
		
		
		# 0b0000
		#   8421
		bitmask = @vert_bitmask
		verts = @original_verts.collect{ |x|  x.clone }
		verts.each_with_index do |vert, i|
			if bitmask & (1 << i) != 0 # check if bit at position i is set
				vert.x += displacement.x
				vert.y += displacement.y
			end
		end
		
		@new_verts = verts
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		# @entity.resize!(@width, @height, @anchor)
		
		offset = CP::Vec2.new(0,0)
		@entity[:physics].shape.set_verts! @new_verts, offset
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		# @entity.resize!(@original_width, @original_height, @anchor)
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