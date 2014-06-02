# Assuming the following structure between Entity and Action, as well as Memento
module ThoughtTrace

class Entity
	module Actions
		class Action
			class Memento
				
			end 
		end
	end
end

class Foo < Entity
	module Actions
		class Bar < Action 
			class Memento < Actions::Memento
				
			end 
		end
	end
end


end







class Entity
	# TODO: Specify how Actions are attached to Entity objects
	# + specify API
	# + specify how Action interface names are related to the Actions themselves
		# manually specify interface name?
		# derived from class name?
	# The Action classes are stored on the Entity class (used as factories)
	# but should they be accessed only though the class, or through an instance as well?
		# allowing access through an instance may be slightly more convenient,
		# but first exposure to this API may be by using an instance of Entity
		# which may make it seem like the Actions can only be accessed through an instance,
		# rather than it being a convenience feature.
	def initialize
		
	end
	
	class << self
		# name styled after things like "const_get" and "instance_variable_get"
		# Recursively looks for an action of a particular name within the inheritance tree
		# Should not dig deeper than Entity, as Entity is what holds the Action structure.
		def action_get(action_name)
			klass = self
			
			begin
				return klass::Actions.const_get action_name
			rescue NameError => e
				if klass == Entity
					# base of the chain
					# recursion base case
					
					# No where left to look, so just raise the exception again
					# (this is correct, not a stub)
					
					raise
				else
					# continue recursive traversal
					
					klass = klass.superclass
					return klass.action_get(action_name)
				end
			end
		end
	end
	
	# ideally, the exception flow will percolate back "down" the inheritance chain
	# to the child class (the class that originally launched the call)
	# so that the error message on the backtrace can accurately report
	# what class was trying to access what action
end





circle = Circle.new
circle.actions[:move] # like methods, actions are actually stored on the class, not the instance
# use a class instance variable instead of a class variable, so that changes do not get "inherited"
# by child classes
# ie) each class in the hierarchy should have it's own list of actions

# if the desired action is not attached to the current class, percolate up the inheritance chain


















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
	
	def draw
		# This should be the only phase where it is necessary to check if @active is set.
		# The other phases should either not be called when @active is unset, or will set @active.
		@active.draw if @active
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




# TODO: sketch out how Haz-style structure applies to input event parsing system.
# TODO: sketch out how input event system interfaces with ActionFlowController



# TODO: Make sure new system involving interactions between Action and entity.method allows for things like the inter-related properties required for Text resizing.
# (this was one of the major objectives of this overhaul)




# TODO: Update documentation to reflect new Action structure and philosophy
# Actions are no longer about high-level control over the backend data from Components
# Action now house code needed to execute procedures using a combination of button and mouse inputs
# Components are namespaces for core functionality
# entity#methods manipulate data from anywhere in the Entity (including Components)
# Actions cause change by firing entity#methods
# precise method sequence is held in the nested Memento class for each Entity subclass
# this compartmentalization allows for easy undo / redo
# as well as the potential for extracting method sequences for macros etc
	# ruby methods can be treated as objects,
	# which can be handled much like procs.
	# src: http://viget.com/extend/convert-ruby-method-to-lambda
# 
# (some of these ideas are written in new_actions.rb)







# controls overall flow
# Will oversee the entire process, from extracting an Entity from the space,
# to firing the appropriate actions as necessary.
# Should illustrate program flow, sort of like a 'main' method.
	# controls operations for one input event binding
	# should assume that multiple instances will be used in tandem
class ActionFlowController
	attr_reader :action_bindings
	
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
		
		
		
		
		# TODO: may want to create a better interface to bind these things visually once GUI systems are operational. Not sure how to make this any better in text form. Gonna be weird no matter how you do it, and nested Hashes are straightforward to implement.
		@action_bindings = {
			:selection => {
				:press => nil,
				:hold => nil
			},
			:existing => {
				:press => nil,
				:hold => nil
			},
			:empty => {
				:press => nil,
				:hold => nil
			}
		}
		
		
		
		@action_controller = nil
	end
	
	# start operation
	def press(point)
		entity = @space.point_query_best(point, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil)
		category = self.categorize(entity)
		
		click_and_drag = self.resolve_action_symbols(entity, category)
		
		
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
	
	# NOTE: Setting of the click and drag controller to nil is done to wipe state. Do not want unnecessary Actions hanging around. That's just likely to cause errors. Don't want anything firing on accident.
	
	
	
	
	
	def draw
		# Should be the only phase where you have to check if variable is set.
		# Same reasoning as in ClickAndDragController#draw delegation
		@action_controller.draw if @action_controller
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
	
	
	
	# Having a #resize for circle is kinda unnecessary,
	# but will will be necessary for rectangle and text,
	# so might as well have one here for unified interface.
	# This allows for Actions to always call methods with the same name
	# This allows for easy discoverability, for when you want to do things code-side
	def resize(r)
		self.radius = r
	end
	alias :resize :radius=
	
	action :resize
	
	# NOTE: If you store polymorphic actions under their respective classes, it would be easier to find them. Could automate where to look for actions, and look for them just by their class names. The current structure is kinda funky, because you're using naming convention to do the work of namespacing.
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
		# called on first tick
		def press(point)
			setup(point)
		end
		
		# called each tick
		def hold(point)
			# IMPLEMENTATION core
			past, future = update(point)
			
			# MEMO creation (pseudo return)
			memo_class = self.class.const_get 'Memento'
			@memo = memo_class.new(@entity, past, future)
			@memo.forward
		end
		
		# called on final tick
		def release(point)
			cleanup(point)
			
			#NOTE: If #press runs, and then #release (no #hold) @memo will be nil. May want to do something about that, because having to check for returns that are nil might get annoying.
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
	# TODO: consider that writing new versions of Memento may be unnecessary if the Memento always passes the @future / @past value(s) to #forward / #reverse. That's not currently what's happening necessarily, but that might be a good direction to go in.
	class Memento < Action::Memento
		# set future state
		def forward
			@entity.resize(@future)
		end
		
		# set past state
		def reverse
			@entity.resize(@past)
		end
	end
end
