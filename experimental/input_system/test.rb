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

class Input
	CLICK = 0
	DRAG  = 1
	
	ACTION_NAME = 0
	TARGET = 1
	
	def initialize(keyboard, mouse, space, action_factory, history_queue)
		@keyboard = keyboard
		@mouse = mouse
		@space = space
		@action_factory = action_factory
		@history_queue = history_queue
		
		
		
		
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
		
		
		
		
		
		@state = :idle
	end
	
	def update
		# update input subsystems
		@keyboard.update
		@mouse.update
		
		
		
		# update state machine
		
		# when mouse button goes down, -> click
		# when mouse movement delta > threshold, -> drag
		# when mouse button goes up, -> release
	end
	
	
	def click(point)
		# keyboard key state
		# mouse button state
		
		# mouse movement deltas
		delta = 0
		
		
		
		
		
		
		accelerators = keyboard.active_accelerators # get active accelerators in some way
		mouse_buttons = mouse.active_buttons
		
		action_name_list = 	mouse_buttons.collect do |mb|
		                   		action_name = @mouse_bindings[mb][accelerators][CLICK]
		                   	end
		
		# convert action names into actions
		# TODO: need to prevent two actions that both manipulate items in the space from firing at the same time. Want to allow item drag + camera move though (not a double entity transform)
		
		
		
		
		
		possible_targets = get_target_list(@space, point)
		
		
		
		# figure out which target out of the stack of items under the cursor is the best choice
		target_entity = possible_targets[0] # just an example
		
		
		
		
		
		# TODO: resolve all actions
		
		# do this for all action names
		
			# get specific action object based on entity used as target
			action = @action_factory.create(target_entity, action_name_list[0])
			
			
			
			
			action.first_target = @down_point
			
			@active_action = action
			
			
			# action not added to history queue until completion
			# (click actions are often canceled, in order to facilitate drag actions)
			
		
		
		
		
		
		# what type-level actions are there, other than the spawn actions?
		
	end
	
	def drag(point)
		# cancel click action, and transition to drag action
		
		accelerators = keyboard.active_accelerators # get active accelerators in some way
		mouse_buttons = mouse.active_buttons
		
		action_name_list = 
			mouse_buttons.collect do |mb|
				action_name = @mouse_bindings[mb][accelerators][DRAG]
				
			end
		
	end
	
	def release(point)
		# finish up action associated with the released button(s)
		@mouse.released_buttons.each do |mb|
			# active_actions[mb].
		end
		
		
		
		
		
		
		
		
		
		
		# finish up action, or cancel it
		@up_point = mouse.position_in_space
		action.first_target = @up_point
		
		
		@history_queue << action
	end



	def draw
		# for all active actions
		@active_action.draw
	end
	
	
	
	# TODO: what happens when you hit left and right buttons down at the same time? both are Event-bound to fire things that eventually calls this part of the code, but this part of the code base assumes that the 4-key-phases will each only be called one at a time. THIS COULD CAUSE MASSIVE ERRORS. PLEASE RECTIFY IMMEDIATELY
	def press(event_name)
		
	end
	
	def hold(event_name)
		
	end
	
	def release(event_name)
		
	end
	
	def cancel(event_name)
		
	end

	
	private
	
	
	def get_target_list(space, point)
		layers=CP::ALL_LAYERS, group=CP::NO_GROUP
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
		
		
		
		
		# format for the data
		# 
		#                 click                  drag    
		# binding => [[action_name, target_type], [action_name, target_type]]
		# ex)  [] => [[nil, nil],                 [:move, 'Entity']]
		data = {
			:left => {
				[]                       => [[nil, nil], [nil, nil]],
				[:shift]                 => [[nil, nil], [nil, nil]],
				[:control]               => [[nil, nil], [nil, nil]],
				[:alt]                   => [[nil, nil], [nil, nil]],
				[:shift, :control]       => [[nil, nil], [nil, nil]],
				[:shift, :alt]           => [[nil, nil], [nil, nil]],
				[:control, :alt]         => [[nil, nil], [nil, nil]],
				[:shift, :control, :alt] => [[nil, nil], [nil, nil]]
			},
			
			:right => {
				[]                       => [[nil, nil], [nil, nil]],
				[:shift]                 => [[nil, nil], [nil, nil]],
				[:control]               => [[nil, nil], [nil, nil]],
				[:alt]                   => [[nil, nil], [nil, nil]],
				[:shift, :control]       => [[nil, nil], [nil, nil]],
				[:shift, :alt]           => [[nil, nil], [nil, nil]],
				[:control, :alt]         => [[nil, nil], [nil, nil]],
				[:shift, :control, :alt] => [[nil, nil], [nil, nil]]
			},
			
			:middle => {
				[]                       => [[nil, nil], [nil, nil]],
				[:shift]                 => [[nil, nil], [nil, nil]],
				[:control]               => [[nil, nil], [nil, nil]],
				[:alt]                   => [[nil, nil], [nil, nil]],
				[:shift, :control]       => [[nil, nil], [nil, nil]],
				[:shift, :alt]           => [[nil, nil], [nil, nil]],
				[:control, :alt]         => [[nil, nil], [nil, nil]],
				[:shift, :control, :alt] => [[nil, nil], [nil, nil]]
			},
		}
		
		
		# start ods parsing to get input bindings
		cell_blocks = {:left => "A6:E13", :right => "G6:K13", :middle => "A20:E27"}
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
			
			formatted_data.each do |binding, click_action, click_target, drag_action, drag_target|
				data[mouse_button][binding] = [
												[click_action, click_target],
												[drag_action, drag_target]
											]
				
				
			end
		end
		
		# data.each do |k,v|
		# 	puts "#{k.inspect} => #{v.inspect}"
		# end
		
		return data
	end
end