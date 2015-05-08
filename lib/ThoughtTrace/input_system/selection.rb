module InputSystem


class Selection
	attr_reader :group
	
	def initialize
		@group = ThoughtTrace::Groups::Group.new
	end
	
	def update
		@group.update
	end
	
	def draw(space)
		@group.draw(space) unless @group.empty?
	end
	
	
	
	# Clear selection, and remove the related Group from the document
	def clear(document)
		# NOTE: what are you gonna do when trying to clear selection? Need to remember that the Selection variable is being passed around to a bunch of subsystems. What happens when that value needs to be changed?
			# Does the active selection group need to be wrapped, such that the selection can be managed better?
			# That may work out,
			# because having methods like 'clear_selection'
			# is rather bad:
			# would rather have them be methods of some Selection class
		document.space.groups.delete @group
	end
end



end