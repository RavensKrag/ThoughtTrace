module ThoughtTrace
	class Rectangle
		module Actions


# Change dimensions of Rectangle by moving edges.
# Aspect ratio is LOCKED.
class Resize < ThoughtTrace::Rectangle::Actions::Edit
	MARGIN = 20 # this currently does nothing
	MINIMUM_DIMENSION = self.superclass::MINIMUM_DIMENSION
	
	initialize_with :entity
	
	# called on first tick
	def press(point)
		super(point)
		@origin = point
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		super(point)
		@delta = point - @origin
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		# undo()
		# NOTE: only need to run undo in the case of corner scaling, but it must be done before verts are examined, so it can't be isolated into the :vert case branch.
		
		
		type, target_indicies = CP::Shape::Rect::VEC_TO_TRANSFORM_DATA[@grab_handle.to_a]
		
		# p target_indicies
		
		new_verts = @entity[:physics].shape.verts
		diagonal  = new_verts[1]
		
		# store original dimensions before any transforms
		original_width  = @entity[:physics].shape.width
		original_height = @entity[:physics].shape.height
		
		
		# compute minimum dimensions
		minimum_x, minimum_y = minimum_dimensions(diagonal)
		
		
		
		
		case type
			when :edge
				# these two lines stolen from CP::Shape::Rect#resize_by_delta!
				a,b = target_indicies.collect{|i| new_verts[i] }
				axis = ( a.x == b.x ? :x : :y )
				
				
				
				# TODO: consider possible problems of dividing delta by two. Should you use integer division? The underlying measurements are pixels, so what happens when you divide in half? Will you ever lose precision?
				
				
				# -----
				# Compare these two ratios:
				# > minimum dimension calculation
				# > scale the secondary axis
				# 
				# The two ratios are similarly calculated, but you can't reuse the same variable.
				# The top ratio is based on the which side is longer, 
				# but the bottom ratio is based on which side is being directly manipulated.
				# -----
				
				
				
				# Scale the edge along the axis shared by it's verts
				# Then, scale along the other axis
				if axis == :x
					# primary x
					@entity[:physics].shape.resize_to_point!(@grab_handle, @point, minimum_x)
					
					
					# secondary y
					ratio = diagonal.y / diagonal.x
					
					new_width  = @entity[:physics].shape.width
					new_height = new_width * ratio
					
					delta = new_height - original_height
					
					
					a = CP::Vec2.new(0,  1)
					b = CP::Vec2.new(0, -1)
					@entity[:physics].shape.resize_by_delta!(a, a*delta/2, minimum_y)
					@entity[:physics].shape.resize_by_delta!(b, b*delta/2, minimum_y)
				else # axis == :y
					# primary y
					@entity[:physics].shape.resize_to_point!(@grab_handle, @point, minimum_y)
					
					
					# secondary x
					ratio = diagonal.x / diagonal.y
					
					new_height = @entity[:physics].shape.height
					new_width = new_height * ratio
					
					delta = new_width - original_width
					
					
					a = CP::Vec2.new( 1, 0)
					b = CP::Vec2.new(-1, 0)
					@entity[:physics].shape.resize_by_delta!(a, a*delta/2, minimum_x)
					@entity[:physics].shape.resize_by_delta!(b, b*delta/2, minimum_x)
				end
				
				
				
			when :vert
				# should perform calculations completely within local space
				# (this allows for advanced coordinate space manipulations, ex: body rotation)
				
				center = @entity[:physics].shape.center
				vert = new_verts[target_indicies.first]
				diagonal = (vert - center).normalize
				# NOTE: this is not the same diagonal from the other branch
				
				local_point = @entity[:physics].body.world2local(@point)
				point = local_point
				point -= center
					# perform projection relative to center
					# (  this coordinate space can not be rotated or skewed
					#    so you can get in / out via translation only   )
					point = point.project(diagonal)
				point += center
				
				
				
				# all calculations in local space
				# some calculations local to center, rather than local origin
				
				
				
				# NOTE: even if you transform using 'to_point', still have to run 'undo' or the scaling ticks each frame, instead of just once
					# wait wait wait, I think it works now
					# had to convert mouse point to a coordinate space relative to center before projection
					# seems like that worked
				
				# scale each axis separately, so each can be clamped independently
				shape = @entity[:physics].shape
				shape.resize_to_local_point!(CP::Vec2.new(@grab_handle.x,0), point, minimum_x)
				shape.resize_to_local_point!(CP::Vec2.new(0,@grab_handle.y), point, minimum_y)
				
				
			when :center
				# nothing
		end
		
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		super()
	end
	
	# final tick of the Action
	# (used to be called #cleanup)
	def release(point)
		super(point)
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		super(point)
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		# TODO: draw margins to get a better idea of how they should be altered as the shape changes.
		# TODO: consider implementing margin rendering using entities and constraints. Then that data could easily be used to drive the modulation of the margins themselves.
		super()
	end
	
	
	private
	
	def minimum_dimensions(diagonal)
		minimum_x = nil
		minimum_y = nil
		
		
		if diagonal.x <= diagonal.y
			# width limits scaling
			ratio = diagonal.y / diagonal.x
			
			minimum_x = MINIMUM_DIMENSION
			minimum_y = MINIMUM_DIMENSION * ratio
		else
			# height limits scaling
			ratio = diagonal.x / diagonal.y
			
			minimum_y = MINIMUM_DIMENSION
			minimum_x = MINIMUM_DIMENSION * ratio
		end
		
		return minimum_x, minimum_y
	end
end



end
end
end