module InputSystem


class Selection
	attr_reader :group
	
	def initialize(document)
		@document = document
		
		@group = ThoughtTrace::Groups::Group.new
	end
	
	def update
		# NOTE: should make it so the Group is only in the Space when it is non-empty.
			# likewise, only need to update / draw when the group is in the Space (and thus non-Empty.)
			# or to put in another way: Group is only active when the Selection is active
		@group.update
	end
	
	def draw(space)
		@group.draw(space) unless @group.empty?
	end
	
	
	def on_shutdown
		# remove the active selection from the groups collection on shutdown
		@document.space.groups.delete @group
	end
	
	
	
	
	
	# Clear selection, and remove the related Group from the document
	def clear
		# NOTE: what are you gonna do when trying to clear selection? Need to remember that the Selection variable is being passed around to a bunch of subsystems. What happens when that value needs to be changed?
			# Does the active selection group need to be wrapped, such that the selection can be managed better?
			# That may work out,
			# because having methods like 'clear_selection'
			# is rather bad:
			# would rather have them be methods of some Selection class
		
		@document.space.groups.delete @group
	end
	
	# blank out the selection.
	# delete the old one, and add a new one in it's place
	def reset
		clear(document)
		
		@group = ThoughtTrace::Groups::Group.new
		document.space.groups.add @group
	end
	
	
	# NOTE: now that all Groups are always stored in the space.groups collection, point_query_best can get the data it needs.
		# hopefully the selection does not need to know the difference between the active selection, and any other group / prefab?
		# I don't think that it would / should
	
	
	
	# NOTE: selection actions need a way to get all the items currently in the selection, so that they can restore state on Undo.
		# dunno if this is quite the same as serialization pack data though, because it can refer to live data just fine.
	
	def all_items
		@group.each.to_a
	end
	
	
	extend Forwardable
	
	def_delegators :@group, 
		:include?, :size, :empty?,
		:add, :delete, :clear,
		:union!, :difference!, :intersection!
end



end