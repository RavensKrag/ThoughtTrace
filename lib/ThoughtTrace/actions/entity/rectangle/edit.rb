module ThoughtTrace
	class Rectangle
		module Actions


# Change dimensions of Rectangle by using 9-slice style transformation
# No aspect ratio locking.
class Edit < ThoughtTrace::Actions::BaseAction
	MARGIN = 20
	MINIMUM_DIMENSION = 25
	
	initialize_with :entity
	
	# called on first tick
	def press(point)
		# mark the initial point for reference
		@origin = point
		
		# test in which region of the shape the point lies
		# ASSUMPTION: point is already known to lie within the shape
		
		
		# convert to local space
		# find distance to edges using local x,y coordinate system
			# don't need to actually use distance formula,
			# and can get distance even if there's rotation in the shape.
		
		local_point = @entity[:physics].body.world2local point
		m = MARGIN # TODO: need margins to shrink as size gets really small
		w = @entity[:physics].shape.width
		h = @entity[:physics].shape.height
		
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
				1
			end
		
		y = 
			if    local_point.y < ya
				# top
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
		
		# new way favors the low end, old way favors the high end (of a particular axis)
		# don't think you can really tell that about the old code by looking at it though...
		
		
		
		# all 9 slices in order:
		# top to bottom, left to right
		@type          = nil # type of transform
		@vert_indicies = nil # affected verts
		
		# vert order: bottom left, bottom right, top right, top left (Gosu render coordinate space)
		@type, @vert_indicies = 
			case [x,y]
				
				when [-1, -1]
					[:vert,     [3]]
				
				when [ 0, -1] # top
					[:edge,     [2,3]]
				
				when [ 1, -1]
					[:vert,     [2]]
				
				when [-1,  0] # left
					[:edge,     [3,0]]
				
				when [ 0,  0]
					[:center,   [0,1,2,3]]
				
				when [ 1,  0] # right
					[:edge,     [1,2]]
				
				when [-1,  1]
					[:vert,     [0]]
				
				when [ 0,  1] # bottom
					[:edge,     [0,1]]
				
				when [ 1,  1]
					[:vert,     [1]]
				
			end
		
		
		@original_verts    = @entity[:physics].shape.verts
		@original_offset   = @entity[:physics].shape.instance_variable_get(:@offset).clone
		@original_position = @entity[:physics].body.p.clone
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		delta = point - @origin
		
		
		return if delta.zero? # short circuit when there is no movement
		
		
		verts = @original_verts.collect{ |vec|  vec.clone  }
		
		case @type
			when :edge
				# scale the edge along the axis shared by it's verts
				a,b = @vert_indicies.collect{|i| verts[i] }
				axis = ( a.x == b.x ? :x : :y )
				
				
				@vert_indicies.each do |i|
					eval "verts[#{i}].#{axis} += delta.#{axis}"
				end
				
			when :vert
				# move one main vert on both axis,
				# and two secondary verts one axis each, in accordance with the main one.
				i = @vert_indicies.first
				
				main  = verts[i]
				
				other = verts.select.with_index{ |vert, index| index != i  }
				a = other.find{ |vert|  vert.x == main.x }
				b = other.find{ |vert|  vert.y == main.y }
				
				
				
				main.x += delta.x
				main.y += delta.y
				a.x += delta.x
				b.y += delta.y
			when :center
				# do nothing
		end
		
		
		clamp_dimensions!(verts)
		# NOTE: this assumes you are only stretching in one direction at a time.
		# ex) if you stretch outwards horizontally (rescale x axis)
		# then the clamp will not perform as expected
		
		
		
		
		
		
		
		
		@new_verts = verts
		# @offset    = CP::Vec2.new(0,0)
		@offset    = verts[3] * -1
		# this vert is by default (0,0) in local space,
		# so you need to restore it to it's default position as the local origin.
		# if you don't, then width / height calculations get weird
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		@entity[:physics].shape.set_verts!(@new_verts, @offset)
		@entity[:physics].body.p =  @original_position - @offset
		
		# checking to make sure the @offset modifies verts as expected (it does)
		# p @entity[:physics].shape.verts.collect{|v|  v.to_s }
		
		
		# NOTE: little bit of jitter on counter-steering
		
		
		
		# w = @entity[:physics].shape.width
		# h = @entity[:physics].shape.height
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@entity[:physics].shape.set_verts!(@original_verts, @original_offset)
		@entity[:physics].body.p = @original_position
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
		# TODO: should visualize margins on mouseover or something. By the time you have activated the edit action, you already have to know kinda where the margin is.
		
		# NOTE: currently visualization changes, but actual margins are always constant.
		
		# @a ||= CP::Vec2.new(0,0)
		# @b ||= CP::Vec2.new(0,0)
		# ThoughtTrace::Drawing.draw_line(
		# 	$window,
		# 	@a,@b,
		# 	thickness:20, z_index:100000
		# )
		
		
		
		color  = Gosu::Color.argb(0xffFFFF00)
		weight = 2
		z      = 1000
		
		
		w = @entity[:physics].shape.width
		h = @entity[:physics].shape.height
		
		
		# TODO: need margins to shrink as size gets really small
		# transform progression of the smaller of the two sides
		# into a bounded linear quantized sequence, and
		# transform that into super-linear final output sequence
		min_side = [w,h].min
		i = Math.sqrt(min_side/2) # approx of the inverse function of the side progression?
		
		seq = [1,2,3,5,8,13,25]   # limit of this sequence should ideally be MARGIN (currently 20)
		
		max_i = seq.length - 1
		i = max_i if i > max_i
		
		margin = seq[i]
		
		m = margin
		
		
		
		xL = 0
		xa = m
		xb = w-m
		xR = w
		
		yT = 0
		ya = m
		yb = h-m
		yB = h
		
		
		[
			[[xa,yT], [xa,yB]],
			[[xb,yT], [xb,yB]],
			[[xL,ya], [xR,ya]],
			[[xL,yb], [xR,yb]]
		].each do |a, b|
			
			$window.translate *@entity[:physics].body.p.to_a do
			
				a = CP::Vec2.new(*a)
				b = CP::Vec2.new(*b)
				ThoughtTrace::Drawing.draw_line(
					$window,
					a,b,
					color:color, thickness:weight, line_offset:0.5, z_index:z
				)
				
			end
			
			
		end
	end
	
	
	
	
	
	
	private
	
	
	# limit minimum size (like a clamp, but lower bound only)
	def clamp_dimensions!(verts)
		vec = (verts[1] - verts[3])
		width  = vec.x
		height = vec.y
		
		
		verts.zip(@original_verts).each do |vert, original|
			[
				[:x, width],
				[:y, height]
			].each do |axis, length|
				
				
				if vert.send(axis) != original.send(axis)
					# vert has been transformed on the given axis
					
					# if the dimension on this axis is too short...
					if length < MINIMUM_DIMENSION
						# counter-steer in the direction of the original vert
						direction = ( vert.send(axis) > original.send(axis) ? 1 : -1 )
						# by an amount that would make the dimension equal the minimum
						delta = MINIMUM_DIMENSION - length
						
						
						eval "vert.#{axis} += #{delta} * #{direction} * -1"
					end
				end
				
				
			end
		end
		
	end
end



end
end
end