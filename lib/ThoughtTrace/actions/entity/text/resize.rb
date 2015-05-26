module ThoughtTrace
	class Text < Rectangle
		module Actions


class Resize < Rectangle::Actions::Resize
	MARGIN = 50 # this currently does nothing
	MINIMUM_FONT_HEIGHT = 10
	
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
		
		# simple ratio solution courtesy of this link
		# http://tech.pro/tutorial/691/csharp-tutorial-font-scaling
		@delta = point - @origin
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		# NOTE: Want to always limit the minimum HEIGHT on resize. Don't really care about what the width is. This applies to Text only, not general rectangles.
		
		# grab_handle = @grab_handle
		# minimum_dimension = MINIMUM_FONT_HEIGHT
		# point = @point
		
		
		undo()
		
		counter_steer_anchor = ->(grab_handle){
			countersteer_handle = grab_handle * -1
			x = countersteer_handle.to_a
			type, target_indidies = CP::Shape::Rect::VEC_TO_TRANSFORM_DATA[x]
			
			
			local_anchor = 
				case type
					when :edge
						target_indidies
							.collect{  |i|    @entity[:physics].shape.vert(i)    }
							.reduce{   |a,b|  CP::Vec2.midpoint(a,b)                 }
					when :vert
						i = target_indidies.first
						@entity[:physics].shape.vert(i)
					else
						return # short-circuit when you attempt to use action on center
				end
			
			return local_anchor
		}
		
		
		
		
		
		
		# prep for counter-steering
		local_anchor = counter_steer_anchor[@grab_handle]
		
		anchor = @entity[:physics].body.local2world(local_anchor)
		
		
		# set width and height
		type, target_indidies = CP::Shape::Rect::VEC_TO_TRANSFORM_DATA[@grab_handle.to_a]
		
		origin =
			case type
				when :edge
					target_indidies
						.collect{  |i|    @entity[:physics].shape.vert(i)    }
						.reduce{   |a,b|  CP::Vec2.midpoint(a,b)                 }
				when :vert
					i = target_indidies.first
					@entity[:physics].shape.vert(i)
			end
		
		dh = @delta.y
		dh *= -1 if @grab_handle.y < 0
		height = @entity.height + dh
		
		
		# NOTE: currently resizes correctly on height, but not on width (because the delta is currently only looking at the change in the y direction). But the core logic is currently set around picking a height, so that's why.
		
		
		height = height.round # rounding needs to happen somewhere to prevent jitter. this works.
		
		h = [height, MINIMUM_FONT_HEIGHT].max
		w = @entity.font.width(@entity.string, h)
		
		grab_handle = CP::Vec2.new(1,1)
		point       = CP::Vec2.new(w,h)
		
		@entity[:physics].shape.resize!(
			grab_handle, :local_space, point:point, lock_aspect:false
		)
		
		
		
		# counter-steer
		local_anchor = counter_steer_anchor[@grab_handle]
		@entity[:physics].right_hand_on_red(local_anchor, anchor)
			# NOTE: what you really want is to save the local anchor in normalized space, so that you can use the exact same anchor twice. but that still requires the computer to calculate what the local anchor is in NEW non-normalized space. So even though that would be more humanistic, it may be worse for performance. (also floating point errors)
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
		# NOTE: consider adjusting margins for Text resize, such that the bottom margin matches up with the baseline of the text.
		super()
	end
	
	private
	
	def margin(w,h)
		super(w,h)
	end
end



end
end
end