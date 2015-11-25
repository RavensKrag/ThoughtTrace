module ThoughtTrace


# Controls overall execution flow for all input systems.
# Like a main method for the entire input system.
# 
# As it is a "main", this class is more a portion of ThoughtTrace proper,
# rather than something than can be externalized.
# This is reflected in the module chosen to hold this class.

















# what happens when you press multiple buttons?
# left   - edit
# right  - move
# middle - camera

# camera actions can be combined with in-space entity actions
# but you don't really want multiple actions on entities happening at the same time

# so, the constraint is about overlap in action types,
# it's not really about button mappings at all


# raw input -> complex input events -> actions that effect the document

require 'roo'

class InputManager
	# TODO: control mouseover effects from this class as well
	
	attr_reader :mouse, :buttons
	
	def initialize(window, document)
		@window = window
		
		# TODO: should probably just pass the window and the document
		# TODO: take note of what things would need to be updated if the bound document were to shift
		@document = document
		
		# TODO: need to figure out if the document (and enclosed data) should be passed to subsystems as they are initialized, or only as they need them.
			# latter would allow for changing the document more freely,
			# but maybe the whole input system just needs to be refreshed
			# when you have a new document?
		
		# TODO: properly implement mouse.
		@mouse = InputSystem::Mouse.new window, @document.camera
		
		
		@keyboard = InputSystem::Keyboard.new window
		
		
		# TODO: figure out if the selection Group needs to be added to the Space or something. How are Groups being tracked?
		@selection = InputSystem::Selection.new @document
		
		@text_input = ThoughtTrace::TextInput.new
		
		
		
		
		# manages many input events
		# input events correspond to button presses
		# those buttons can be keyboard keys, mouse buttons, or gamepad buttons
		@buttons = InputSystem::ButtonParser.new
		
		
		
		
		# hold actions flow controllers, so that input manager can direct action UI drawing
		# need to draw actions so that they can show polymorphic interface information
		# NOTE: storing actions this way means that the button parser doesn't have to know anything about the input system.
		@actions = Array.new
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		# TODO: consider moving the action factory into the Document, if it would somehow make document switching easier to just bind the action factory present inside each document, instead of having to re-init the factories. But maybe that structure just doesn't work for some reason.
		@action_factory = InputSystem::ActionFactory.new(
							@selection,
							
							:selection => @selection,
							:text_input => @text_input,
							
							:space => @document.space,
							:clone_factory => @document.prototypes,
							:styles => @document.named_styles
						)
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		# input bindings
		
		
		# NOTE: currently want to declare target type here, because it makes it easier to see the full binding relationships in one place. Makes it clearer if you want to effect only one type of Entity.
		
		filepath = "/home/ravenskrag/Code/Tools/ThoughtTrace/notes/input_bindings.ods"
		@mouse_bindings = load_input_binding_config(filepath, "Sheet4")
		
		
		# mouse wheel
			# zoom                ( zoom the entire document. images GPU scale, text smart scale )
			# abstraction layer   ( ladder of abstraction: explicit detail vs high-level )
			# render layer        ( relative z-index depth sort. swap z-index with other items. )
		
		
		# edit action only edits exposed properties,
		# if you peel the abstraction back, you can edit individual properties
		# ie) move a vert with the move action
		
		# abstraction stepping works on a particular tree-like segment of the graph.
		# on any one element in the tree you can...
		# + step up:    limits the whole tree to view the parent layer ( for that subgraph )
		# + step down:  expands the view to include the children of that node
		
		@mouse_wheel_actions = {
				[]                        => [:zoom],
				[:shift]                  => [:render_layer],
				[:control]                => [:abstraction_layer],
				[:alt]                    => [nil],
				[:shift, :control]        => [nil],
				[:shift, :alt]            => [nil],
				[:control, :alt]          => [nil],
				[:shift, :control, :alt]  => [nil]
		}
		
		
		
		# keyboard input split into various types
		# - text input
		# - accelerators
		# - non-text keys that perform context-sensitive actions
		# 
		# - maybe some other categories?
		@keyboard_bindings = {
			Gosu::KbF8 => :link_styles,
			# all selected items now use the same style
			
			
			Gosu::KbReturn => :press_enter_event
			# creates new line of text when there is an active text object
		}
		
		
		
		
		
		
		
		
		
		# === new plan ===
		# inputs bound to actions
		# each input binding triggers a separate action
		# actions can be targeted or non-targeted (should specify on the action)
		# if an action is targeted, then the input system will grab an appropriate target
		# and feed it in to the action at the proper phase
		
		# are there specific types of targets?
		
		
		
		# --proposal:
		# use 'join' action to add new entities into a group
		# use 'split/rip' to remove entities from a group
		# (not literally the same actions, just this name)
		# these names originally are for manipulating substrings in strings
		# it makes sense to extend that functionality to entity / group relationships
		
		
		
		
		
		# want to make sure you can move the camera while manipulating objects,
		# but you don't want two object manipulation actions occurring simultaneously
		# what exactly should be the course of action in that case?
		# you are certainly physically capable of hitting both buttons at once,
		# so this scenario MUST be considered
		
		
		
		
		
		
		
		# mouse actions
			# click and drag
			# different states with updating looping flow
			# modified by keyboard state
			# launch Actions that can be called through other mechanisms
		# mouse wheel actions
			# may change variables that effect other actions
			# affects user interface layer, but not the way raw Actions are triggered
		# keyboard actions
			# single button press causes something to happen
			# should also be undo-able
			# not sure if these are Action or just Events
			# can affect the current selection
				# can they effect more than that?
			
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		# callbacks = ThoughtTrace::Events::PressEnter.new @document.space, @text_input, @document.prototypes
		# event = InputSystem::ButtonEvent.new :enter, callbacks
		
		# event.bind_to keys:[Gosu::KbReturn], modifiers:[]
		
		# @buttons.register event
		
		
		
		# callbacks = ThoughtTrace::Events::LinkStyles.new @selection, action_factory
		# event = InputSystem::ButtonEvent.new :link_styles, callbacks
		
		# event.bind_to keys:[Gosu::KbF8], modifiers:[]
		
		# @buttons.register event
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		# one active action per button?
		
		
		
		# left and right activate at the same time (same frame startup. unlikely but possible)
		# left activates when right is active
		# right activates when left is active
		# => in any of these cases only one action at most can be active.
		# when you can't disambiguate, fire no actions at all
		
		
		
		
		
		# separate MouseInputSystem instances each store one press-hold-release / click-drag flow
		@mouse_inputs = [
			[:left_click,   Gosu::MsLeft,   InputSystem::MouseInputSystem.new(@mouse)],
			[:right_click,  Gosu::MsRight,  InputSystem::MouseInputSystem.new(@mouse)],
			[:middle_click, Gosu::MsMiddle, InputSystem::MouseInputSystem.new(@mouse)]
		]
		
		@mouse_inputs.each do |mb, button_id, mouse_input_system|
			event = InputSystem::ButtonEvent.new(mb, mouse_input_system)
			event.bind_to keys:[button_id], modifiers:[]
			@buttons.register event
		end
		
		
		
		
		@mouse_inputs.each do |mb, button_id, mouse_input_system|
			mouse_input_system.parse_callback do |phase, point|
				# this block needs to return an initialized Action object
				# (do NOT call press yet)
				
				# NOTE: add debug print statement to show the current inputs
				# (mouse button, accelerators, click / drag)
				# when no action is bound
				# (functionality from current MouseInputSystem that I'm about to break)
				
				
				accelerators = @keyboard.active_accelerators
				
				name_and_target = @mouse_bindings[mb][accelerators][phase]
				
				action_name = name_and_target[:action]
				target_type_string = name_and_target[:target]
				
				
				
				space = @document.space
				
				# only really need to do this when you trigger an action with an Entity target
				potental_targets = get_target_list(space, point)
				# TODO: make a tighter condition for when this fires, as an optimization
				
				
				# get list of potential targets
				# this list has already been sorted by some criteria,
				# so any additional manipulations on this list must not alter that
				# (currently calculating position of center, and surface area)
				
				
				# select the target based on some criteria, including the known type
				# (NOTE: need to save the target somehow for the drag transition)
				# if you need the original mouse position, it will have to be fed into this block
				
				
				
				# must consider groups, queries, and individual entities
				
				# TODO: must consider groups as well.
				# Need to take into consideration the abstraction level
				# - you found a group: do you want to treat it as a group or an entity?
					# (should be able to do both)
				# - do you want to look at the group itself, or peel back the abstraction?
				
				
				
				
				# translate type string into class object
				target_type = 
					if target_type_string == 'none'
						:none
					elsif target_type_string == 'Camera'
						ThoughtTrace::Camera
					elsif target_type_string == 'Query'
						ThoughtTrace::Queries::Query
					else
						if basic_type?(target_type_string)
							# puts "basic type detected"
							# p BASIC_TYPE_ASSOC
							# p BASIC_TYPE_ASSOC.assoc(target_type_string)
							BASIC_TYPE_ASSOC.assoc(target_type_string).last
						elsif prefab_type?(target_type_string)
							# TODO: remember to search linked documents for prefab definition as well, once linked documents have been implemented
							raise "Using prefab types as action targets has not yet been implemented"
						else
							raise "Unexpected error"
						end
					end
				
				# p target_type_string
				puts "target type string: #{target_type_string}"
				puts "target type class: #{target_type.inspect}"
				
				
				# determine target object based on type
				target =
					case target_type
						when :none
							nil
						when ThoughtTrace::Camera
							@document.camera
						else
							# find a target from the list of potential targets based on class
							potental_targets.find do |x|
								if target_type == ThoughtTrace::Queries::Query and x[:query]
									# looking for a query, and potential target has a query component attached to it
									true
								elsif x.is_a? target_type
									# not looking for a query, but found an object of the right type
									true
								end
							end
					end
				
				# TODO: possible short-circuit when target == nil
				
				
				
				
				# action = @action_factory.create(target, action_name)
				# TODO: examine action factory, and consider that part of the pathway
				
				# ===== below is code from ActionFactory#create
				
				conversions = {
					:selection => @selection,
					:text_input => @text_input,
					
					:space => @document.space,
					:clone_factory => @document.prototypes,
					:styles => @document.named_styles
				}
				# TODO: warn if any of these variables are nil
				
				# entity conversion must be specified here, because it is dynamic
				# (as opposed to in the initializer, which would be static)
				conversions[:entity] = target
				conversions[:group] = target if target.is_a? ThoughtTrace::Groups::Group
				# NOTE: this method of group specification should take into abstraction layering
				
				
				
				# this is the part where things start to get really weird 
				
				
				
				
				
				
				action_class = get_action(target, target_type, action_name)
				# NOTE: may return ThoughtTrace::Actions::NullAction
				
				# under new system,
				# if you say "I want an Entity action"
				# that means "treat the target as an Entity, and get the action"
				# but if you say "I want a Text action" that means you specifically want the Text version of the polymorphic function
				
				
				
				
				
				
				# may be able to keep the following code wholesale
				# not sure that any of it really needs to change
				
				
				# NOTE: remember that the action class holds both the argument list, and the obj allocator
				args   = action_class.argument_type_list.collect{|type| conversions[type] }
				action = action_class.new(*args)
				
				
				# warn about undefined actions
				# not something you want to throw an exception for
				# (some buttons just don't have things bound to them, and that's ok)
				warn "#{type.inspect} does not define action '#{action_name}'" if action.null_action?
				
				
				# if no action is found, the NullAction will be returned
				# this way, the rest of the pathway will still work,
				# even though it's stubbed
				action
			end
		end
		
		
		
		@mouse_actions = @mouse_inputs.collect{|arr| arr.last }
		
		
		
		
		
		
		
		
		
		# press mouse buttons
			# prevent startup of left when right is active and vice versa
		
		
		# hold mouse buttons
		# cancel mouse
		# transition to drag actions
		
		
		# release mouse buttons
		
		
	end
	
	def button_down(id)
		[
			@buttons,
			# @mouse_input
		].each do |x|
			x.button_down(id)
		end
	end
	
	def update
		[
			@buttons,
			@text_input,
			@selection
			# @mouse_input
		].each do |x|
			x.update
		end
	end
	
	# draw things in world space
	def draw
		# NOTE: Input system is drawn after a flush of the draw queue, so UI will always be drawn on top of any element in the Space. It will never be occluded by the elements in the Space, not even the selection highlight ( that could actually be bad )
		
		@actions.each do |action|
			action.draw @mouse.position_in_space
		end
		
		@mouse_actions.each{ |x| x.draw  }
		
		@text_input.draw(@document.space)
		# @mouse_input.draw		
	end
	
	def button_up(id)
		[
			@buttons,
			# @mouse_input
		].each do |x|
			x.button_up(id)
		end
	end
	
	def on_shutdown
		@selection.on_shutdown
	end
	
	
	
	
	private
	
	
	def get_target_list(space, point)
		layers=CP::ALL_LAYERS
		group=CP::NO_GROUP
		
		selection = space.point_query(point, layers, group, limit_to:nil, exclude:nil)		
		
		
		# Sort by area
		selection.sort_by! do |x|
			x[:physics].shape.area
		end
		
		# Get the smallest area values, within a certain threshold
		# Results in a certain margin of what size is acceptable,
		# relative to the smallest object
			# NOTE: This is where the number of Entities being considered can drop.
			
		first_area = selection.first[:physics].shape.area
		size_margin = 1.8 # percentage
		# TODO: Tweak margin
		
		selection = selection.select do |o|
			o[:physics].shape.area.between? first_area, first_area*(size_margin)
		end
		
		selection.sort_by! do |x|
			# Assuming that the shapes all have their center on their local origin
			# TODO: need to update this to use proper #center calculations
			distance = x[:physics].body.pos.dist point
			
			# Listed in order of precedence, but sort order needs to be reverse of that
			[x[:physics].shape.area, distance].reverse
		end
		
		
		return selection
	end
	
	# determine what polymorphic version of the action to fire,
	# based only on the name of the action, and the type of the caller
	def get_action(obj, action_name)
		# entity actions
			# manipulating
			# creating new entities from prototypes
			# creating new entities from existing ones
		# group actions
		# query actions
		# constraint actions
		# camera actions
		# space actions
	end
	
	
	
	
	
	BASE_CLASSES = [
		ThoughtTrace::Entity, ThoughtTrace::Actions::EmptySpace, ThoughtTrace::Groups::Group
	]
	# Recursively looks for an Action of a particular name.
	# Should not dig deeper than Entity, as Entity is what holds the Action structure.
	# 
	# name styled after things like "const_get" and "instance_variable_get"
	# 
	# ideally, the exception flow will percolate back "down" the inheritance chain
	# to the child class (the class that originally launched the call)
	# so that the error message on the backtrace can accurately report
	# what class was trying to access what action
	# 
	# obj    -- object trying to fire an Action
	# klass  -- current class under which we're looking for Action objects (changes with recursion)
	# name   -- name of the Action desired
	def get_action(obj, klass, name)
		# expects names as standard symbols, rather than in constant-symbol format
		# ex) expected    -  :move_over_there
		#     rather than -  :MoveOverThere
		
		# NOTE: I think this is a cleaner interface, but it requires a bunch of string manipulation. As this is something that needs to be called very often, it may become a major source of latency.
		# The weird part is really that you're using symbols in a not-very-symbol-like way
		# so the solution may actually be just to use Strings instead
		# as constant lookup can also be done using strings
		
		
		name_const = name.to_s.constantize
		# p [klass, name, name_const]
		
		begin
			return klass::Actions.const_get name_const
		rescue NameError => e
			# Traverse the hierarchy to find a class that can yield the desired Action.
			# Mostly, you will traverse the class inheritance hierarchy,
			# but there are some exceptions.
			
			if BASE_CLASSES.include? klass
				# you have reached the bottom of the chain,
				# the root of the the tree.
				# The recursion stops here
				
				# end of the road:
				# this is the base of the entire Action search system.
				# If no action has been found by this point, the action is not defined.
				warn "#{obj.class} does not define #{name || '<NIL>'}, nor does it's ancestors"
				return ThoughtTrace::Actions::NullAction
			else
				# trigger recursion to find the Action in question
				parent = get_parent(obj, klass)
				
				return get_action(obj, parent, name)
			end
		end
	end
	
	# helper method for get_action
	# ( obj and klass are the same as defined by get_action )
	def get_parent(obj, klass)
		# NOTE: the klass check prevents infinite looping.
			# first time:  obj.class != klass => triggers recursion on non-standard 'parent'
			# other times: obj.class == klass => standard superclass traversal
			# ( without check, you would always get the first case, because it's listed first )
		
		# --- try taking specially defined exceptions
		if klass == ThoughtTrace::Queries::Query and obj[:query]
			# if the base object has a Query component
			# you need to check the base object's class, as well as the core Query class
			return obj.class
		elsif klass == ThoughtTrace::Groups::Group and @selection.include? obj
			# Group doesn't define an action, then just use the Entity action instead.
			return obj.class
		# -------------------------------
		else  # but if there aren't any, just go the standard way 
			return klass.superclass
			
			# NOTE: Modules do not have a 'superclass', so if you end up calling this on a module, it will break. Currently do not have a need to do that, but it may come up in the future.
		end
	end
	
	
	
	
	# order in this list determines type precedence.
	# system will infer that an entity is of a higher type before a lower one
	BASIC_TYPE_ASSOC = [
		['Circle',    ThoughtTrace::Circle],
		['Text',      ThoughtTrace::Text],
		['Rectangle', ThoughtTrace::Rectangle],
		['Entity',    ThoughtTrace::Entity]
	]
	# returns true if type is among one of the core types defined by the system
	# (query is not considered a basic type, as it is a component)
	def basic_type?(entity_type_string)
		BASIC_TYPE_ASSOC.any?{  |a| a.first == entity_type_string  }
	end
	
	# returns true if the type is one defined by a prefab in the document
	def prefab_type?(document, entity_type_string)
		return false
	end
	
	
	
	
	
	
	
	
	
	def parse_cell_range(cell_range_string)
		c1,r1, c2,r2 = cell_range_string.scan(/(\D*)(\d*):(\D*)(\d*)/).first
		r1 = r1.to_i
		r2 = r2.to_i
		
		# p [c1, c2]
		return c1,r1, c2,r2
	end
	
	def load_input_binding_config(filepath, sheet_name)
		puts "loading mouse input bindings from .ods file"
		
		spreadsheet = Roo::Spreadsheet.open(filepath)
		
		# p spreadsheet.methods
		# p spreadsheet.sheets
		# p spreadsheet.sheet("Sheet4").methods.grep /each/
		# spreadsheet.sheet("Sheet4").each do |x|
		# 	p x.class
		# 	p x.size
		# 	p x
		# 	break
		# end
		
		
		
		
		data = Hash.new
		
		# start ods parsing to get input bindings
		cell_blocks = {
			:left_click   => "A6:E13",
			:right_click  => "G6:K13",
			:middle_click => "A20:E27"
		}
			# cell ranges given in in excel notation
		
		
		
		
		
		cell_blocks.each do |mouse_button, cell_range|
			# parse range into usable variables
			c1,r1, c2,r2 = parse_cell_range(cell_range)
			
			# iterate over range and get the data
			raw_data = 	(r1..r2).collect do |r|
			           		(c1..c2).collect do |c|
			           			# puts spreadsheet.sheet("Sheet4").cell(c,r)
			           			
			           			spreadsheet.sheet(sheet_name).cell(c,r)
			           		end
			           	end
			
			# parse strings, and store information in the "data" hash declared at the beginning
			formatted_data = 
				raw_data.collect do |binding, click_action, click_target, drag_action, drag_target|
					# convert accelerator names to list of symbols
					if binding == "NONE"
						binding = [] 
					else
						binding = binding.split('+').collect{|x| x.strip.to_sym }
					end
					
					# convert click / drag action names to symbols
					click_action, drag_action =
						[click_action, drag_action].collect do |input|
							input.tr(' ', '_').to_sym unless input.nil?
						end
					
					# format click / drag targets
					# (currently just leaving them as strings)
					# click_target, drag_target =
					# 	[click_target, drag_target].collect do |input|
					# 		input unless input.nil?
					# 	end
					
					
					
					
					
					p [binding, click_action, click_target, drag_action, drag_target]
					[binding, click_action, click_target, drag_action, drag_target]
				end
			
			
			# ===========
			# Actual data format specified here
			# ===========
			formatted_data.each do |binding, click_action, click_target, drag_action, drag_target|
				data[mouse_button] ||= Hash.new
				
				
				
				# NOTE: binding is always an array of symbols
				data[mouse_button][binding] = {
					:click => {
						:action => click_action,	:target => click_target
					},
					:drag => {
						:action => drag_action, 	:target => drag_target
					}
				}
				
			end
		end
		
		
		
		# input: pair = (button, [list, of accelerators])
		# note that is this is a scalar + Vec3, it's literally a Quaternion
		# 
		# output: pair = (action_name, target)
		
		
		
		
		# (button, [list, of accelerators])
		# (click / drag)
		# => (action_name, action_target)
		
		
		# test = [
		# 	[[nil, nil], [nil, nil]],
		# 	[[nil, nil], [nil, nil]],
		# 	[[nil, nil], [nil, nil]]
		# ]
		# x = [:left, :right, :middle]
		# y = # [accelerator list, in order]
		# xi = # index of 'mouse_button' in x
		# yi = # index of 'binding' in y
		# pos = xi*y.size + yi # all binds for one mb close together; big chucks for one mouse button
		
		# test[pos] # => [[nil, nil], [nil, nil]]
		
		
		
		# data.each do |k,v|
		# 	puts "#{k.inspect} => #{v.inspect}"
		# end
		
		return data
	end
end



end