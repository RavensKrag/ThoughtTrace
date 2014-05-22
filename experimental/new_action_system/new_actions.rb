class Entity
	def initialize
		
	end
end


# controls click and drag flow
class ClickAndDragController
	def initialize(click_handler, drag_handler)
		# minimum distance for drag to be detected,
		# in whatever units are used for the Space
		@delta_threshold = 20
		
		
		# NOTE: may not be able to fire the click and drag events like this if the Actions can switch themselves out for other Actions, as was the case with ActionStash.
		# NOTE: handlers are currently just raw Actions, but you could weave another abstraction layer between ClickAndDragController and Action if it becomes necessary.
		@click = click_handler
		@drag = drag_handler
		
		@active = nil
	end
	
	def press(point)
		@origin = point
		
		@click.press(@origin)
		@active = @click
	end
	
	def hold(point)
		if @active == @click and delta_exceeded?(point)
			@click.cancel(point)
			@drag.press(@origin)
			
			@active = @drag
		end
		
		@active.hold(point)
	end
	
	def release(point)
		@active.release(point)
	end
	
	def cancel(point)
		@active.cancel(point)
	end
	
	
	private
	
	def delta_exceeded?(point)
		displacement = point - @origin
		delta = displacement.length
		
		return delta > @delta_threshold
	end
end


# provides three-state system used in a variety of places
class Haz
	def initialize
		
	end
	
	def setup(point)
		
	end
	
	def update(point)
		
	end
	
	def cleanup(point)
		
	end
	
	
	# "cancel" isn't part of the core 3 states,
	# but is necessary for many operations
	def cancel(point)
		
	end
end

# juggles executing Haz objects
class Qux
	def initialize
		
	end
	
	
	# code taken from ActionStash
	def initialize
		@active = nil
	end
	
	# put a new thing into the collection space
	# this action will displace any action which currently inhabits the space
	# (consider returning the old action, so the action doesn't just disappear into the void)
	# (would really only be one pointer to the action, though, rather than the action itself)
	def pass_control(action, point)
		# setup new one
		action.setup self, point
		
		# if there's an action currently in play,
		# clean up old one, and be rid of it
		if @active
			@active.cleanup
			@active = nil
		end
		
		# store the new action
		@active = action
	end
	
	# update the tracked action
	def update(point)
		@active.update point if @active
	end
	
	# Get rid of the currently tracked action. (Make sure to clean up)
	def clear
		if @active
			@active.cleanup
			@active = nil
		end
	end
end








# controls overall flow
	# controls operations for one input event binding
	# should assume that multiple Bar objects will be used in tandem
class Bar
	def initialize(space, selection, stash)
		@space = space
		@selection = selection
		@stash = stash
		# TODO: Should probably pass @selection to Action objects as they are initialized.
		# TODO: Consider the removal of the Action stash. May not be needed in new format.
			# was needed for automated handling of Actions
			# (now irrelevant. should be using direct interfaces for that purpose)
			
			# was needed to allow Actions to baton pass to other Actions
			# (not sure if that's still necessary or not)
		
		@action_controller = nil
	end
	
	# start operation
	def press(point)
		entity = @space.point_query_best(point, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil)
		category = self.categorize(entity)
		
		click_and_drag = resolve_action_symbols(entity, category)
		
		
		# NOTE: May want to refrain from allocating and deallocating ClickAndDragController all the time. But you would have to remember to reset the internal state of the object before using it again. Easier for now to just make new ones.
		@action_controller = ClickAndDragController.new(*click_and_drag)
		@action_controller.press(point)
	end
	
	# adjust operation interactively
	def hold(point)
		@action_controller.hold(point)
	end
	
	# complete operation
	def release(point)
		@action_controller.release(point)
		@action_controller = nil
	end
	
	# revert to the state before this structure was invoked
	def cancel(point)
		@action_controller.cancel(point)
		@action_controller = nil
	end
	
	
	
	private
	
	def categorize(entity)
		if entity.nil?
			# space is empty at desired point
			return :empty
		elsif @selection.include? entity
			# entity is part of the currently active selection
			return :selection
		else
			# assuming we have found an existing Entity
			# but that it has no special characteristics
			return :existing
		end
	end
	
	# resolve symbols into actual Actions
	def resolve_action_symbols(entity, category)
		[:click, :drag].collect do |event|
			action_name = @action_bindings[category][event]
			entity.class.actions[action_name].new(@space, @stash, entity)
		end
	end
end






class Circle < Entity
	# wrapping backend methods seems trivial for radius alteration,
	# but makes sense for things like rectangle rescaling
	# which require a lockdown point
	# or text scaling, in which height and width are conjoined
	# May want to just wrap everything for the sake of a unified interface.
	def radius
		@components[:physics].shape.radius
	end
	
	def radius=(r)
		@components[:physics].shape.set_radius! r
	end
	
	
	action ResizeCircle
end


class Action
	# NOTE: You might think that setting @entity in #press would remove the need to allocate a new ClickAndDragController object all the time. But that just means that the controller would have to be more aware of how Action works, which is not desirable.
	
	def initialize(space, stash, entity)
		@space = space # for queries and modifications to the space (ex, new objects)
		
		@stash = stash # for passing control to other Action objects for chaining actions
		@entity = entity
	end
	
	# outer API
	# used to give external code something to call
		def press(point)
			setup(point)
		end
		
		def hold(point)
			# IMPLEMENTATION core
			past, future = update(point)
			
			# MEMO creation (pseudo return)
			memo_class = self.class.const_get 'Memento'
			@memo = memo_class.new(@entity, past, future)
			@memo.forward
		end
		
		def release(point)
			cleanup(point)
			
			return @memo
		end
		
		def cancel
			# the memo is always created during the #hold phase
			# so, if there is no @memo, no #hold has been executed yet
			# this means that no change has yet been made to the @entity
			# thus, nothing needs to be reversed
			# (more importantly, nothing can be reverted without the @memo)
			@memo.reverse if @memo
		end
	
	
	
	
	# inner API
	# separate from outer API so that you don't have to think about
	# creating or managing memos in child class implementation
		# called on first tick
		def setup(point)
			
		end
		
		# return two values: past and future used by Memento
		# called each tick
		def update(point)
			
		end
		
		# not often used, but you can define this callback if you need it
		# really, just added for completeness
		def cleanup(point)
			
		end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw(point)
		
	end
	
	
	
	# perform the transformation here
	# by encapsulating the transform in this object,
	# it becomes easy to redo / undo actions as necessary
	# (Consider better name. Current class name derives from a design pattern.)
	# (this class also has ideas from the command pattern, though)
	class Memento
		# TODO: insure that #forward and #reverse maintain the redo / undo paradigm. Currently, you could run #forward twice in a row, to apply the operation twice. That's not desirable.
		def initialize(entity, past, future)
			@entity = entity
			
			@past = past     # encapsulates the condition before execution
			@future = future # encapsulates condition after execution
		end
		
		# set future state
		def forward
			
		end
		
		# set past state
		def reverse
			
		end
	end
end

class ResizeCircle < Action
	def initialize(space, stash, entity)
		super(space, stash, entity)
	end
	
	
	# called on first tick
	def setup(point)
		# mark the initial point for reference
		@origin = point
		
		@original_radius = @entity.radius
	end
	
	# return two values: past and future used by Memento
	# called each tick
	def update(point)
		# Alter the size of the circle by an amount equal to the radial displacement
		# Away from the center is positive,
		# towards the center is negative.
		
		displacement = point - @origin
		
		# project displacement along the radial axis
		center = @entity[:physics].body.p.clone
		r = (point - center).normalize
		
		radial_displacement = displacement.project(r)
		magnitude = radial_displacement.length
		
		# flip sign if necessary
		magnitude = -magnitude unless displacement.dot(r) > 0
		
		
		
		# limit minimum size
		radius = @original_radius + magnitude
		radius = MINIMUM_DIMENSION if radius < MINIMUM_DIMENSION
		
		
		
		return @original_radius, radius
	end
	
	
	# display information to the user about the current transformation
	# called each tick
	def draw(point)
		
	end
	
	
	
	# perform the transformation here
	# by encapsulating the transform in this object,
	# it becomes easy to redo / undo actions as necessary
	# (Consider better name. Current class name derives from a design pattern.)
	# (this class also has ideas from the command pattern, though)
	class Memento < Action::Memento
		# set future state
		def forward
			@entity.radius = @future
		end
		
		# set past state
		def reverse
			@entity.radius = @past
		end
	end
end
