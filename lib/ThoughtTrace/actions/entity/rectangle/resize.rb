module ThoughtTrace
	class Rectangle
		module Actions


# Change dimensions of Rectangle by moving edges.
# Aspect ratio is LOCKED.
class Resize < ThoughtTrace::Rectangle::Actions::Edit
	MARGIN = 20
	MINIMUM_DIMENSION = 10
	
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
		
		
		type, target_indicies = CP::Shape::Rect::VEC_TO_TRANSFORM_DATA[@grab_handle.to_a]
		
		# p target_indicies
		
		new_verts = @entity[:physics].shape.verts
		
		case type
			when :edge
				# store original dimensions before any transforms
				width  = @entity[:physics].shape.width
				height = @entity[:physics].shape.height
				
				
				
				
				# scale the edge along the axis shared by it's verts
				a,b = target_indicies.collect{|i| new_verts[i] }
				axis = ( a.x == b.x ? :x : :y )
				
				
				
				minimum = self.class.superclass::MINIMUM_DIMENSION
				@entity[:physics].shape.resize_to_point!(@grab_handle, @point, minimum)
				
				
				
				# TODO: consider possible problems of dividing delta by two. Should you use integer division? The underlying measurements are pixels, so what happens when you divide in half? Will you ever lose precision?
				
				# TODO: minimum dimension for aspect ratio locked scaling needs to take into account aspect ratio, or else on the extreme low end, you ignore aspect ratio and converge to square.
				
				
				# then, scale along the other axis
				if axis == :x
					# scale along y
					original_width = width
					width  = @entity[:physics].shape.width
					
					ratio = width.to_f / original_width.to_f
					new_height = height * ratio
					
					delta = new_height - height
					
					
					a = CP::Vec2.new(0,  1)
					b = CP::Vec2.new(0, -1)
					@entity[:physics].shape.resize_by_delta!(a, a*delta/2, minimum)
					@entity[:physics].shape.resize_by_delta!(b, b*delta/2, minimum)
				else # axis == :y
					# scale along x
					original_height = height
					height = @entity[:physics].shape.height
					
					ratio = height.to_f / original_height.to_f
					new_width = width * ratio
					
					delta = new_width - width
					
					
					a = CP::Vec2.new( 1, 0)
					b = CP::Vec2.new(-1, 0)
					@entity[:physics].shape.resize_by_delta!(a, a*delta/2, minimum)
					@entity[:physics].shape.resize_by_delta!(b, b*delta/2, minimum)
				end
				
				
				
			when :vert
				center = @entity[:physics].shape.center
				vert = new_verts[target_indicies.first]
				diagonal = (vert - center).normalize
				
				vec = @delta.project(diagonal)
				
				minimum = self.class.superclass::MINIMUM_DIMENSION
				@entity[:physics].shape.resize_by_delta!(@grab_handle, vec, minimum)
				
				
			when :center
				# nothing
		end
		
		
		
		# offset = new_verts[3] * -1
		# # this vert is by default (0,0) in local space,
		# # so you need to restore it to it's default position as the local origin.
		# # if you don't, then width / height calculations get weird
		
		# @entity[:physics].shape.set_verts!(new_verts, offset)
		# @entity[:physics].shape.body.p -= offset
		
		
		# # then, scale along the other axis
		# midpoint = CP::Vec2.midpoint(a,b)
		# midpoint_world = @entity[:physics].body.local2world(midpoint)
			
		# 	# list = [:x, :y]
		# 	# list.delete(axis)
		# 	# scale_axis = list.first
		# 	p verts.collect{|p| p.to_s}
		# 	if axis == :x
		# 		# scale along y
		# 		original_width = width
		# 		width += @delta.x
				
		# 		ratio = width.to_f / original_width.to_f
		# 		height = height * ratio
				
				
		# 		verts[0].y = height
		# 	else # axis == :y
		# 		# scale along x
		# 		original_height = height
		# 		height += @delta.y
				
		# 		ratio = height.to_f / original_height.to_f
		# 		width = width * ratio
				
				
		# 		verts[2].x = width
		# 	end
		
		# a,b = target_indicies.collect{|i| verts[i] }
		# new_midpoint = CP::Vec2.midpoint(a,b)
		# new_midpoint_world = @entity[:physics].body.local2world(new_midpoint)
		
		# shift = new_midpoint_world - midpoint_world
		# @entity[:physics].body.p += shift
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