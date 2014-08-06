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


class Foo
	CLICK = 0
	DRAG  = 1
	
	def initialize(space, mouse)
		@space = space
		@mouse = mouse
		
		
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
		
		
		
		@mouse_button_converter = {
			Gosu::MsLeft  => :left_click,
			Gosu::MSRight => :right_click
		}
		
		@key_parser = AcceleratorCollection.new(
							[:shift,   Gosu::KbLeftShift,   Gosu::KbRightShift]
							[:control, Gosu::KbLeftControl, Gosu::KbRightControl]
							[:alt,     Gosu::KbLeftAlt,     Gosu::KbRightAlt]
						)
		
		
		
		
		# @spatial_status = :on_object
		# @mouse_button = :left_click
		# @accelerators = [:shift]
		# @button_phase = CLICK
		@active_action = nil
	end
	
	
	
	def button_down(id)
		@key_parser.button_down(id)
		
		mouse_button_symbol = @mouse_button_converter[id]
		return unless mouse_button_symbol
		
		
		# if there has been a mouse event
		@button_phase = CLICK
		@mouse_button = mouse_button_symbol
		
		
		point = @mouse.point_in_space
		query = @space.point_query_best point
		
		@spatial_status = 
			if query
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
			
			@active_action.cancel if @active_action
			# there is not always a click action associated with the button binding
			
			
			@active_action = nil # discard the old action
			
			
			action = parse_inputs()
			if action
				# there is no guarantee that drag action will exist, either
				
				@active_action = action
				@active_action.press(point)
			end
		end
		
		
		# manage the currently active action, if any
		@active_action.hold(point) if @active_action
	end
	
	
	
	
	
	def button_up(id)
		@key_parser.button_up(id)
		
		
		if action_has_been_released
			@active_action.release(point)
		end
	end
	
	
	
	
	private
	
	
	# given the current state of things, figure out what action you're firing
	# TODO: consider rename
	# TODO: provide queried entity to this method somehow. it is necessary to figure out what action to fire (polymorphic action style)
	# TODO: update rest of code to reflect that this method will never return nil, but instead will generate a null object (or change this method so it returns nil. need to figure out which)
	def parse_inputs
		input_key = [@spatial_status, @mouse_button, @accelerators]
		action_name = @bindings[input_key][@button_phase]
		
		warn "no action bound to #{input_key}" unless action_name
		
		
		
		
		place_to_look, target = 
			case @spatial_status
				when :on_object
					# assuming we have found an existing Entity
					# but that it has no special characteristics
					
					[entity.class, entity]
					
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