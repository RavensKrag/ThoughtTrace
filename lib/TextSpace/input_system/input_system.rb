module TextSpace


class InputSystem
	DIS::Sequence.new(:left_click).tap do |input|
		input.callbacks[:default].tap do |c|
			c.on_press do
				puts "left DOWN #{DIS.timestamp}"
			end
			
			c.on_hold do
				puts "left #{DIS.timestamp}"
			end
		end
		
		input.press_events = [
			DIS::Event.new(Gosu::MsLeft, :down)
		]
		input.release_events = [
			DIS::Event.new(Gosu::MsLeft, :up)
		]
	end
	
	
	
	
	
	
	sequence :left_click do
		# can separate the callbacks from the action detection
		callbacks :default do
			on_press do
				puts "left DOWN #{DIS.timestamp}"
			end
			
			on_hold do
				puts "left #{DIS.timestamp}"
			end
		end
		
		
		
		
		
		
		press_events [
			DIS::Event.new(Gosu::MsLeft, :down)
		]
		
		release_events [
			DIS::Event.new(Gosu::MsLeft, :up)
		]
	end
	
	
	
	
	
	
	
	
	accelerator :shift do
		press_event DIS::Event.new(Gosu::KbLeftShift, :down)
		
		release_event DIS::Event.new(Gosu::KbLeftShift, :up)
	end
	
	accelerator :shift => Gosu::KbLeftShift
	
	accelerator :shift, Gosu::KbLeftShift
	
	
	
	
	
	single :left_click do
		press_event DIS::Event.new(Gosu::MsLeft, :down)
		
		release_event DIS::Event.new(Gosu::MsLeft, :up)
	end
	
	single :left_click => Gosu::MsLeft
	
	single :left_click, Gosu::MsLeft
	
	
	
	
	
	
	chord :shift_left_click => [:shift, :left_click]
	
	chord :shift_left_click, [:shift, :left_click]
	
	
	
	
	
	
	
	
	
	# note that the bindings will eventually be set using spatial data
	# so it's more important that the binding interface be technically sound
	# as opposed to really humanistic and smooth
	
	bind {
		:left_click => LeftClickAction.new
	}
	
	

	
	bind {
		# input => list of actions to fire
					# action names should be interface names, not class constant names
		:left_click =>		[
								'move',
							]
		
		:middle_click =>	[
								'move',
							]
		
		:right_click =>		[
								'move',
							]
	}
	
	
	
	
	
	
	def initialize
		@inputs = []
		@actions = []
		
		
		
		
		@actions = {
			:move => HumanAction.new(:move)
		}
		
		
		
		
							point = @mouse.position_in_world
							layers = CP::ALL_LAYERS
							group = CP::NO_GROUP
							set = nil
		entity_list = @space.point_query_best point, layers, group, set
		
		@actions[:move].press(entity_list)
		
		
		
		
		
		
		@bindings = {
			# input => list of actions to fire
			:right_click => [:move]
		}
		
		
		
		
		
		
		@active_actions = Set.new
		
		
		@mouse = TextSpace::Mouse.new
	end
	
	
	
	# TODO: stop state progression if press does not trigger correctly
	# TODO: pass set of entities to the human action on press
	
	
	# fire one or more events that correspond to the given event as appropriate
	def event_in(event)
		action_list = @bindings[event.name]
		
		action_list.each do |action_name|
			action = @actions[action_name]
			
			
			action.press @mouse.position_in_world
			@active_actions.add action
		end
	end
	
	# maintain the 'hold' state for any active actions
	def process_events
		@active_actions.each do |action|
			action.hold @mouse.position_in_world
		end
	end
	
	# release currently active events associated with the event
	def event_out(event)
		action_list = @bindings[event.name]
		
		action_list.each do |action_name|
			action = @actions[action_name]
			
			action.release @mouse.position_in_world
			@active_actions.delete action
		end
	end
	
	
	
	
	def button_down(id)
		
	end
	
	def button_up(id)
		
	end
	
	
	
	
	def event_in(event)
		action_list = @bindings[event.name]
		
		# resolve symbols
		actions = action_list.collect{ |name| @actions[name] }
		
		# process actions
		actions.each do |action_name|
			action.press
			@active_actions.add action
		end
	end
end



end