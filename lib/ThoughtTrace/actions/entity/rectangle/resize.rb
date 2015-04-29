module ThoughtTrace
	class Rectangle
		module Actions


# Change dimensions of Rectangle by moving edges.
# Aspect ratio is LOCKED.
class Resize < ThoughtTrace::Rectangle::Actions::Edit
	MARGIN = 20
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
		undo()
		# NOTE: only need to run undo in the case of corner scaling, but it must be done before verts are examined, so it can't be isolated into the :vert case branch.
		
		
		type, target_indicies = CP::Shape::Rect::VEC_TO_TRANSFORM_DATA[@grab_handle.to_a]
		
		# p target_indicies
		
		new_verts = @entity[:physics].shape.verts
		
		case type
			when :edge
				# store original dimensions before any transforms
				original_width  = @entity[:physics].shape.width
				original_height = @entity[:physics].shape.height
				
				
				
				
				# compute minimum dimensions
				diag  = new_verts[1]
				
				minimum_x = nil
				minimum_y = nil
				
				if original_width <= original_height
					# width limits scaling
					ratio = diag.y / diag.x
					
					minimum_x = MINIMUM_DIMENSION
					minimum_y = MINIMUM_DIMENSION * ratio
				else
					# height limits scaling
					ratio = diag.x / diag.y
					
					minimum_y = MINIMUM_DIMENSION
					minimum_x = MINIMUM_DIMENSION * ratio
				end
				
				
				
				
				
				
				
				# these two lines stolen from CP::Shape::Rect#resize_by_delta!
				a,b = target_indicies.collect{|i| new_verts[i] }
				axis = ( a.x == b.x ? :x : :y )
				
				
				
				
				
				
				# TODO: consider possible problems of dividing delta by two. Should you use integer division? The underlying measurements are pixels, so what happens when you divide in half? Will you ever lose precision?
				
				
				# -----
				# Compare these two ratios:
				# above  ^  minimum dimension calculation
				# below  v  scale the secondary axis
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
					ratio = diag.y / diag.x
					
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
					ratio = diag.x / diag.y
					
					new_height = @entity[:physics].shape.height
					new_width = new_height * ratio
					
					delta = new_width - original_width
					
					
					a = CP::Vec2.new( 1, 0)
					b = CP::Vec2.new(-1, 0)
					@entity[:physics].shape.resize_by_delta!(a, a*delta/2, minimum_x)
					@entity[:physics].shape.resize_by_delta!(b, b*delta/2, minimum_x)
				end
				
				
				
			when :vert
				# NOTE: vert scaling still converges to square, ignoring the aspect ratio.
				center = @entity[:physics].shape.center
				vert = new_verts[target_indicies.first]
				diagonal = (vert - center).normalize
				
				vec = @delta.project(diagonal)
				
				@entity[:physics].shape.resize_by_delta!(@grab_handle, vec, MINIMUM_DIMENSION)
				
				
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
end



end
end
end