module ThoughtTrace
	class Text
		module Actions


class Edit < ThoughtTrace::Actions::BaseAction
	initialize_with :text_input, :clone_factory, :entity, :space
	
	# called on first tick
	def press(point)
		@point = point
		
		@start_i = @entity.nearest_character_boundary(point)
		@end_i = @start_i
	end
	
	# called each tick after the first tick (first tick is setup only)
	# perform calculations to generate the new data, but don't change the data yet.
	# Many ticks of #update can be generated before the final application is decided.
	def update(point)
		@end_i = @entity.nearest_character_boundary(point)
		
		# NOTE: be careful when @end_i < @start_i
		# You can't assume that one will always be bigger than the other.
	end
	
	# Actually apply changes to data.
	# Called after #update on each tick, and also on redo.
	# Many ticks of #apply can be fired before the action completes.
	def apply
		# select from @start_i to @end_i of the active text object in @entity
			# add Text object to clone factory
			# open text input buffer
			# set start and end positions of input buffer
			# resize UI object to show selection
		
		
		# @text_input.add @entity, @entity.nearest_character_boundary(@point)
		
		# @old_prototype = @clone_factory.make ThoughtTrace::Text
		# @clone_factory.register_prototype @entity
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		# @text_input.clear
		# @clone_factory.register_prototype @old_prototype
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
		color = Gosu::Color.argb(0xBB00AAAA)
		
		start_offset = @entity.width_of_first(@start_i)
		end_offset   = @entity.width_of_first(@end_i)
		
		a = @entity[:physics].body.p.clone
		b = @entity[:physics].body.p.clone
		
		a.x += start_offset
		b.x += end_offset
		
		y_offset = @entity[:physics].shape.height / 2
		a.y += y_offset
		b.y += y_offset
		
		# vec = @entity[:physics].body.p
		
		# NOTE: alpha blending doesn't seem to be working with line drawing
		z = @space.entities.index_for(@entity) + @space.entities.offsets[:text_highlight]
		ThoughtTrace::Drawing.draw_line(
			$window, a,b, 
			color:color, thickness:8, line_offset:0.5, z_index:z
		)
		# TODO: create better z-indexed calculation.
		# need to figure out a good way to specify how much space there is in between each Entity z-index, or specify what offsets are allowed? or something. The Action already knows about the Entity, and could know about the Space, it could use the Entity z as a baseline if it wanted to.
	end
end



end
end
end