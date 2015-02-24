# The graphical interface elements of a Constraint
# (kinda like a Decorator: adds extra stuff on top of the standard Constraint functionality)
# (can use the Constraint objects directly if you don't need visualization. ex: optimization)
class ConstraintPackage
	attr_reader :marker_a, :marker_b
	attr_accessor :visualization # NOTE: this is mostly needed for serialization
	
	def initialize(constraint, visualization)
		@constraint = constraint
		@visualization = visualization
		
		@marker_a = EntityMarker.new
		@marker_b = EntityMarker.new
		
		
		@visible = true
		# TODO: get the Entity markers to snap as they are moved
		
		
		
		
		# # Want to keep the tracking markers positioned relative to the centers of the related entities
		# # also, all the tracking objects on one entity should repel each other, so that you can more easily select them with the mouse (may have to do that logic inside of the collider callback?)
		# # NOTE: update to use actual constraints. the constraint declaration here is just a demo
		
		# @move_with = ThoughtTrace::Constraints::MoveWith.new
		
		
		# TODO: in the future, consider implementing constraints as closures with closure bound variables, rather than objects (would need a language that isn't Ruby to do that sort of implementation though)

	end
	
	# returns true if and only if the Constraint fired
	def update
		# NOTE: this feels really weird, because you're attempting to rebind every tick. you only really NEED to update the bindings much less frequently than this. I guess it's only when the markers move? is there a good way to set up a callback for that which would take less work than comparing the pointers on the pair that is attempting to be bound?
		update_bindings()
		
		@constraint.update do
			# this block only fires if the constraint is fired
			# TODO: maybe you want a blocks that fire at other times? like, edge trigger? or just on "no fire"?
			@visualization.activate
			
			return true
		end
		
		
		return false
		
		
		
		
		# # use helper constraints to update the entity markers
		# if @visible # don't update position of markers, unless markers are going to be drawn
		# 	@move_with.call(@marker_a, a)
		# 	@move_with.call(@marker_b, b)
		# end
		# NOTE: the markers need to move when the parents move, but the markers also need to snap to their "parents". this implies moving the markers too far away from the "parents" will break the linkage. (this is partially implemented in the collider already, but it's not totally there yet. no notion of snapping yet.)

	end
	
	def draw
		return if not @visible # allow hiding the visualization (useful for optimization)
		# (by which I mean that abstracted hidden packages can be turned into raw constraints)
		
		a = @marker_a.render_target
		b = @marker_b.render_target
		
		raise "Packaged constraints should always be drawn" if a.nil? or b.nil?
		
		
		@visualization.draw(a,b)
	end
	
	
	
	private
	
	def update_bindings
		# extract entities from tracker objects
		a = @marker_a.constraint_target
		b = @marker_b.constraint_target
		
		if a.nil? or b.nil?
			@constraint.unbind
		else
			@constraint.bind(a,b)
		end
	end
end