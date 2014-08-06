require 'rubygems'
require 'gosu'


# Generate a bunch of the input combinations, so they don't need to be written by hand
->(){
	# keyboard accelerators to modify mouse inputs
	a = [:shift, :control, :alt]
	# all possible combinations of any number of elements from a
	x = a.size.times.collect{|i| a.combination(i+1).to_a }.flatten(1)

	# spatial options
	y = [:on_object, :empty_space]

	# mouse click options
	z = [:left_click, :right_click]

	y.product(z).product(x).collect{|a,b| [a[0], a[1], b] }.each{|x| p x}
	
	# NOTE: need to add the cases where no accelerators are pressed
	
	
	
	
	# # click or drag?
	# w = [:click, :drag]

	# combinations = 
	# 	y.product(z).product(x).product(w)
	# 		.collect{|a,b| [a.first.first, a.first.last, a.last, b] }
	# combinations.each{|x| p x}
}[]


class AcceleratorCollection
	def initialize(*key_conversion_list)
		@conversion_table = Hash.new
		@hash = Hash.new
		
		key_conversion_list.each do |key_symbol, *button_ids|
			button_ids.each do |id|
				@conversion_table[id] = key_symbol
			end
			@hash[key_symbol] = false
		end
	end
	
	def active_accelerators
		@hash.select{ |button_symbol, flag|  flag }.keys
	end
	
	
	def button_down(id)
		key = @conversion[id]
		if key
			@hash[key] = true
		end
	end
	
	def button_up(id)
		key = @conversion[id]
		if key
			@hash[key] = false
		end
	end
end




class InputManager
	def initialize(window, space, camera, clone_factory)
		@window = window
		@space = space
		@camera = camera
		@clone_factory = clone_factory
		
		
		# this could be useful in other parts of the input system
		# regardless, it's good do declare all bindings to lower-level input symbols at this level
		accelerator_collection = AcceleratorCollection.new(
							[:shift,   Gosu::KbLeftShift,   Gosu::KbRightShift]
							[:control, Gosu::KbLeftControl, Gosu::KbRightControl]
							[:alt,     Gosu::KbLeftAlt,     Gosu::KbRightAlt]
						)
		
		
		mouse_button_mapping = {
			Gosu::MsLeft  => :left_click,
			Gosu::MSRight => :right_click
		}
		
		@mouse_input = MouseInputSystem.new(
							@space, @mouse,
							@selection, @text_input, @clone_factory
							accelerator_collection, mouse_button_mapping
						)
	end
end



# TODO: create class that bundles the pieces of data that need to be sent to every Action. It's weird to have to "delegate" all these arguments through the chain of command like this.


class MouseInputSystem
	CLICK = 0
	DRAG  = 1
	
	def initialize(space, mouse, selection, text_input, clone_factory, accelerator_collection, mouse_button_mapping)
		# Necessary for this class only
		@mouse = mouse
		
		# things to send through to Action
		@space = space # @space is used at this level as well, to make the mouse queries
		
		@selection = selection
		@text_input = text_input
		@clone_factory = clone_factory
		
		
		
		
		@bindings = {
			[:on_object,   :left_click,  []]                        => [:edit, :select_sub_text],
			[:on_object,   :left_click,  [:shift]]                  => [nil, :resize],
			[:on_object,   :left_click,  [:control]]                => [:add_to_group, :constrain],
			[:on_object,   :left_click,  [:alt]]                    => [:split, nil],
			[:on_object,   :left_click,  [:shift, :control]]        => [nil, nil],
			[:on_object,   :left_click,  [:shift, :alt]]            => [nil, nil],
			[:on_object,   :left_click,  [:control, :alt]]          => [nil, nil],
			[:on_object,   :left_click,  [:shift, :control, :alt]]  => [nil, nil],
			[:on_object,   :right_click, []]                        => [nil, :move],
			[:on_object,   :right_click, [:shift]]                  => [nil, :duplicate],
			[:on_object,   :right_click, [:control]]                => [:mark_as_query, :link],
			[:on_object,   :right_click, [:alt]]                    => [:join, nil],
			[:on_object,   :right_click, [:shift, :control]]        => [nil, :clone],
			[:on_object,   :right_click, [:shift, :alt]]            => [nil, nil],
			[:on_object,   :right_click, [:control, :alt]]          => [nil, nil],
			[:on_object,   :right_click, [:shift, :control, :alt]]  => [nil, nil],
			[:empty_space, :left_click,  []]                        => [nil, nil],
			[:empty_space, :left_click,  [:shift]]                  => [:spawn_text, nil],
			[:empty_space, :left_click,  [:control]]                => [:spawn_rect, nil],
			[:empty_space, :left_click,  [:alt]]                    => [:spawn_circle, nil],
			[:empty_space, :left_click,  [:shift, :control]]        => [nil, nil],
			[:empty_space, :left_click,  [:shift, :alt]]            => [nil, nil],
			[:empty_space, :left_click,  [:control, :alt]]          => [nil, nil],
			[:empty_space, :left_click,  [:shift, :control, :alt]]  => [nil, nil],
			[:empty_space, :right_click, []]                        => [nil, nil],
			[:empty_space, :right_click, [:shift]]                  => [nil, nil],
			[:empty_space, :right_click, [:control]]                => [:spawn_image, nil],
			[:empty_space, :right_click, [:alt]]                    => [nil, nil],
			[:empty_space, :right_click, [:shift, :control]]        => [nil, nil],
			[:empty_space, :right_click, [:shift, :alt]]            => [nil, nil],
			[:empty_space, :right_click, [:control, :alt]]          => [nil, nil],
			[:empty_space, :right_click, [:shift, :control, :alt]]  => [nil, nil]
		}
		
		
		@mouse_button_converter = mouse_button_mapping
		# button id => :right_click / :left_click
		
		
		@key_parser = accelerator_collection
		
		
		
		
		# @spatial_status = :on_object
		# @mouse_button = :left_click
		# @accelerators = [:shift]
		# @button_phase = CLICK
		@active_action = ThoughtTrace::Actions::NullAction.new "DUMMY NODE"
		@entity = nil
	end
	
	
	
	def button_down(id)
		@key_parser.button_down(id)
		
		mouse_button_symbol = @mouse_button_converter[id]
		return unless mouse_button_symbol
		
		
		# if there has been a mouse event
		@button_phase = CLICK
		@mouse_button = mouse_button_symbol
		
		
		point = @mouse.position_in_space
		@entity = @space.point_query_best point
		
		@spatial_status = 
			if @entity
				:on_object
			else
				:empty_space
			end
		
		@accelerators = @key_parser.active_accelerators
		
		
		
		
		@active_action = parse_inputs()
		@active_action.press
	end
	
	
	
	
	
	def update
		# while you're just checking for updates
		if mouse_exceeded_drag_threshold()
			@button_phase = DRAG
			
			
			@active_action.cancel
			
			@active_action = parse_inputs()
			@active_action.press(@mouse.position_in_space)
		end
		
		
		# manage the currently active action, if any
		@active_action.hold(@mouse.position_in_space)
	end
	
	
	
	
	
	def button_up(id)
		@key_parser.button_up(id)
		
		
		if action_has_been_released
			@active_action.release(@mouse.position_in_space)
			@entity = nil
		end
	end
	
	
	
	
	private
	
	
	# given the current state of things, figure out what action you're firing
	# TODO: consider rename
	def parse_inputs
		input_key = [@spatial_status, @mouse_button, @accelerators]
		action_name = @bindings[input_key][@button_phase]
		
		warn "no action bound to #{input_key}" unless action_name
		
		
		
		
		place_to_look, target = 
			case @spatial_status
				when :on_object
					# assuming we have found an existing Entity
					# but that it has no special characteristics
					
					[@entity.class, @entity]
					
				when :empty_space
					# space is empty at desired point
					
					# no target, because most actions in empty space create new things
					# the target supposed to be a thing which already exists
					# but that doesn't make sense for an action that creates something new
					[ThoughtTrace::Actions::EmptySpace, nil]
			end
		
		
		
		
		
		standard_args = [@space, @selection, @text_input, @clone_factory]
		
		action = place_to_look.action_get(action_name).new(*standard_args,  target)
		
		# TODO: make easy way to check if Action is a the null object for that type of action. Sorta like how you can call #nil? on an object to check if it is nil or not
		if action_name and action.is_a? ThoughtTrace::Actions::NullAction
			warn "#{place_to_look.inspect} does not define action '#{action_name}'"
		end
		
		
		
		
		
		return action
	end
end