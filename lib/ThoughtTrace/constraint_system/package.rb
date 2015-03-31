module ThoughtTrace
	module Constraints


class Package
	attr_accessor :visualization
	attr_reader :constraint
	attr_reader :marker_a, :marker_b
	
	def initialize(constraint, visualization)
		# main initialization
		@pair = Pair.new(constraint)
		@marker_a = Marker.new
		@marker_b = Marker.new
		
		# TODO: figure out how to change color of Visualization based on the type of Constraint that is bound in the Pair
		@visualization = visualization
		
		@visible = true
		
		
		
		# define helper constraints:
		# makes it so that Markers will move when their target Entities are moved
		constraint_object = ThoughtTrace::Constraints::MoveRelative.new
		constraint_object.closure
			.let do |delta|
				delta # no additional offset.
			end
		
		@helpers = Array.new(2)
			@helpers[0] = Pair.new(constraint_object)
			@helpers[1] = Pair.new(constraint_object)
			# Helper constraint pairs are bound in #update_bindings,
			# when marker bindings are copied over.
	end
	
	def update
		update_bindings()
		
		@pair.update do
			# this block only fires when the pair successfully updates
			@visualization.activate
		end
		
		@visualization.update
		
		# NOTE: technically don't need to call #update when nothing is bound, (ie, the Pair in this Package is not bound) but not sure if that 'optimization' actually helps
		@helpers.each{ |h| h.update  }
	end
	
	def draw
		return if not @visible # allow hiding the visualization (useful for optimization)
		# (by which I mean that abstracted hidden packages can be turned into raw constraints)
		
		a = @marker_a.render_target
		b = @marker_b.render_target
		
		raise "Packaged constraints should always be drawn" if a.nil? or b.nil?
		
		
		@visualization.draw(a,b)
	end
	
	
	
	
	
	
	def show
		@visible = true
	end
	
	def hide
		@visible = false
	end
	
	def visible?
		@visible
	end
	
	
	
	
	
	private
	
	def update_bindings
		# NOTE: you don't want to do this all the time, just when you think the bindings may have changed. You don't want to be sending unnecessary bind / unbind commands if you can help it.
		# (state transition edge trigger only. do not fire if you or not changing state.)
		
		
		# extract entities from tracker objects
		a = @marker_a.constraint_target
		b = @marker_b.constraint_target
		
		# same logic as in Pair#bind
		# Only want to commit changes if something has actually changed
		# (should probably only be writing this once though...)
		return if a.equal? @pair.a and b.equal? @pair.b
		
		if a.nil? or b.nil?
			@pair.unbind
			@visualization.unbind
			unbind_helper_constraints()
		else
			@pair.bind(a,b)
			@visualization.bind
			bind_helper_constraints()
		end
	end
	
	def bind_helper_constraints
		@helpers[0].bind(@marker_a, @marker_a.constraint_target) if @marker_a.constraint_target
		@helpers[1].bind(@marker_b, @marker_b.constraint_target) if @marker_b.constraint_target
	end
	
	def unbind_helper_constraints
		@helpers[0].unbind
		@helpers[1].unbind
	end
end



end
end