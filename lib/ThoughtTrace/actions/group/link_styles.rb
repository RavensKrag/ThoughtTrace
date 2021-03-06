module ThoughtTrace
	module Groups
		class Group
			module Actions


class LinkStyles < ThoughtTrace::Actions::OneShotAction
	initialize_with :group
	
	
	# Called on the first tick. Prepare the transform.
	def setup(point)
		
		@target_list = @group.each.to_a
		@old_styles = @target_list.collect{|x| x[:style]  }
		
		
		
		#need to convert the selection to an array
		# before you can figure out what the 'first' element is.
		# however, traversal order of Sets should always be the same
		# (order of insertion)
		@style = @target_list.first[:style]
	end
	
	# Called on the first tick. Applies the transform
	def apply
		@target_list.each do |entity|
			entity.delete_component :style
			entity.add_component @style
		end
	end
	
	# restore original state
	# revert the changes made by all ticks of #apply
	# (some actions need to store state to make this work, other actions can fire an inverse fx)
	def undo
		@target_list.zip(@old_styles) do |entity, style|
			entity.delete_component :style
			entity.add_component style
		end
	end
	
	
	
	
	
	
	
	# NOTE: Action visualizations are not the same as Constraint visualizations
	def update_visualization(point)
		
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw
		
	end
end



end
end
end
end