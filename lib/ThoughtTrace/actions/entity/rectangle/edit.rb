module ThoughtTrace
	class Rectangle
		module Actions


# Change dimensions of Rectangle by using 9-slice style transformation
# No aspect ratio locking.
class Edit < ThoughtTrace::Actions::BaseAction
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
		w = @entity[:physics].shape.width
		h = @entity[:physics].shape.height
		m = margin(w,h)
		
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
		
		@grab_handle = CP::Vec2.new(x,y)
		
		
		
		@original_verts    = @entity[:physics].shape.verts
		@original_position = @entity[:physics].body.p.clone
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		delta = point - @origin
		
		@delta = delta
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		# shape resize method is a one-shot thing,
		# so you must undo the last tick of the action before running the resize again
		# (this is because deltas are per-action rather than per-tick)
		# (probably would not have to undo when using per-tick deltas)
		# NOTE: per-tick deltas introduce a lot of drift (at least for naive implementation)
		undo()
		
		return if @delta.zero? # short circuit when there is no movement
		
		
		@entity[:physics].shape.resize_by_delta!(@grab_handle, @delta, MINIMUM_DIMENSION)
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@entity[:physics].shape.set_verts!(@original_verts, CP::Vec2.new(0,0))
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
		
		
		m = margin(w,h)
		
		
		
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
	
	def margin(w,h)
		# default: MARGIN = 20
		
		# TODO: need margins to shrink as size gets really small
		# transform progression of the smaller of the two sides
		# into a bounded linear quantized sequence, and
		# transform that into super-linear final output sequence
		min_side = [w,h].min
		i = Math.sqrt(min_side/2) # approx of the inverse function of the side progression?
		
		seq = [1,2,3,5,8,13,25]   # limit of this sequence should ideally be MARGIN (currently 20)
		
		max_i = seq.length - 1
		i = max_i if i > max_i
		
		seq[i]
	end
end



end
end
end