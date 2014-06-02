module ThoughtTrace


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
		
		
		@mouse = ThoughtTrace::Mouse.new
	end
	
	
	
	# TODO: stop state progression if press does not trigger correctly
	# TODO: pass set of entities to the human action on press
	
	
	
	
	
	# Use active events to fire actions
	
	
	# fire one or more events that correspond to the given event as appropriate
	def event_in(event)
		action_list = @bindings[event]
		
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
		action_list = @bindings[event]
		
		action_list.each do |action_name|
			action = @actions[action_name]
			
			action.release @mouse.position_in_world
			@active_actions.delete action
		end
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	def button_down(id)
		event_in ThoughtTrace::Event.new(id, :down)
	end
	
	def button_up(id)
		event_out ThoughtTrace::Event.new(id, :up)
	end
end



end
















# accelerator system
# simple system
# only works with single keys, combined with accelerators (typically: shift, ctrl, alt)
class Foo
	def initialize
		@accelerators = [
			:shift,
			:control,
			:alt
		] # accelerators
		
		
		# not accelerators
		@main_keys = [
			:a, :b, :o
		]
		
		
		# events that can be fired, mapped to input sequences
		@events = {
			[:shift,   :a] => lambda{ },
			[:control, :b] => ->(){  },
			[:o] => ->(){   }
		}
		
		
		# maps raw button inputs to human readable names
		# Gosu already provides some names, but I want a structure independent of that
		# also, this means you can provide application-specific names
		# and potentially, you could switch around the underlying mapping for a particular name
		# without that much hassle, which is good when you're prototyping
		
		# this also means the system can easily figure out what inputs can be safely ignored
		# if an input ID is not registered in the button map,
		# that means that it is not being used in any binding
		# -> the ID is in the button map IFF the button is being used in a binding
		@button_map = {
			Gosu::MsLeft => :left_click,
			Gosu::MsRight => :right_click,
			
			Gosu::KbA => :a,
			Gosu::KbB => :b,
			Gosu::KbO => :o,
		}
		
		
		
		# when main key depressed, fire event
		# can fire separate event for unmodified event, vs each and every accelerated event
		
		
		# list of keys currently being held
		@held = Set.new
	end
	
	
	def button_down(id)
		button = @button_map[id]
		
		# short circuit for unregistered buttons
		return if button.nil?
		
		
		
		@held.add button if @accelerators.include? id
		
		
		if @main_keys.include? button
			# fire event
			
			
			# modify event with all available accelerators
			# but do NOT expend accelerators to do so
			
				# accelerators should probably be listed in a particular order,
				# independent of when they had been pressed, so that it
				# becomes easier to match them up with events
		end
		
		
		
		
		
		
		@held.add button
	end
	
	def update
		
	end
	
	# def button_up(id)
	# 	@held.delete id
	# end
	
	def button_up(id)
		button = @button_map[id]
		
		@held.delete button
	end
end






# sourced from tutorials:
# http://www.jstiles.com/Blog/How-To-Implement-Keyboard-Shortcuts-In-Your-Web-Application---Part-1
# http://www.jstiles.com/Blog/How-To-Implement-Keyboard-Shortcuts-in-Your-Web-Application---Part-2
# http://code.tutsplus.com/tutorials/detecting-key-combos-the-easy-way--active-8608

class InputSystem
	def initialize
		@active_keys = Set.new
		# may want to have two sets:
		# one for IDs and one for characters generated by the keys
		# so that you can specify inputs by code or by character as necessary
		
		
		# all available events that can be fired
		@events = []
		
		
		# list of currently active events
		@collection = []
	end
	
	
	
	
	
	def button_down(id)
		@active_keys.add id
		
		@collection.concat self.press
		@collection.concat self.foo
	end
	
	def update
		@collection.each do |event|
			event.hold
		end
	end
	
	def button_up(id)
		@active_keys.delete id
		
		
		@collection.delete_if do |event|
			if event.keys.include? id or event.mods.include? id
				event.release
				
				true # pseudo return
			end
		end
	end
	
	
	
	
	
	private
	
	# handle combinations of keys with / without modifiers ex: (a+b shift,control) (x shift) (esc)
	def press
		# NOTE: this implementation will execute all active combinations. not sure if more than one combination could be active during one press, but if that happens, things could get weird. Alternative would be to execute only the first match, but that would mean that the order in which events are declared would set an implicit priority.
		
		launched_events = 
			events.select do |e|
				# check modifiers first, because that's probably a shorter list
				# makes for a faster short-circuit
				
				next unless all_mods_pressed(e)
				next unless all_keys_pressed(e)
				
				
				true # pseudo return
			end
		
		launched_events.each{ |e| e.call }
	end
	
	
	
	# handle sequences of inputs
	# this is fighting-game style combo detection
	
	# TODO: add timestamps to button recording if you want this to actually work
	# NOTE: not actually checking timestamps right now, so it will not work quite as expected.
	# NOTE: @active_keys is currently a set, so you can't detect strings of multiple buttons (ex: AAA) so this is pretty super useless.
		# TODO: consider keeping "keys" and "modifiers" in Event as sets, but turning @active_keys into an array
		# NOTE: ideally, it should probably be a circular buffer or something.
	def foo
		# Assuming that each object in @active_keys resolves to one character in the string
		
		
		joined_input_string = @active_keys.inject(""){|all,i| all << i.to_s}
			# must manually convert i to string
			# if you don't, and it's an integer,
			# the concat operator will interpret it as a codepoint instead of a literal int
		
		# TODO: create @sequences array, filled with sequences to look for
		
		matched_sequences = 
			@sequences.select do |seq|
				combo = seq.keys.join('')
				
				
				# NOTE: the $ character is a zero-width match for the end of the string
				regexp = /#{combo}$/
				joined_input_string =~ regexp # check if there is a match
			end
		
		matched_sequences.each{ |seq| seq.call }
	end
	
	public
	
	
	
	
	
	
	
	
	def register(event)
		@events.push event
	end
	
	def unregister(event_name)
		@events.delete_if{ |event| event.name == event_name }
	end
	
	
	
	
	
	
	
	class Event
		attr_reader :name, :keys, :modifiers
		
		def initialize(name, keys: [], modifiers: [], &block)
			@name = name
			@event = block
			
			
			raise "Must specify at least one key" if keys.empty?
			
			@keys = keys.to_set
			@modifiers = modifiers.to_set
		end
		
		def call(*args)
			@event.call(*args)
		end
	end
	
	# TODO: Consider feeding Event an object that implements #press, #hold, and #release instead of just one block for a method callback. Might be better than having Event implement these methods itself.
		# Or you could made the base Event implement the methods, and create a subclass that serves as a wrapper for the action flow controller, I suppose
	
	# TODO: Consider if @keys and @modifiers need to be Sets. Might be better to leave them as arrays. (Only because Set#subset? is implemented with a linear scan.)
		# NOTE: currently using #include? in InputSystem#button_up to determine if chords have been invalidated.
	
	
	
	private
	
	# NOTE: #subset? checks each element of self against the given set
	
	def all_keys_pressed(event)
		event.keys.subset? @active_keys
	end
	
	def all_mods_pressed(event)
		event.modifiers.subset? @active_keys
			# all? will return true for an empty array
			# which is what you want in the case where no modifiers are listed
	end
end


CTRL J+K+L
SHIFT,ALT Q
ESCAPE
SHIFT ESCAPE



[Gosu::KbLeftControl], [Gosu::KbJ, Gosu::KbK, Gosu::KbL]
[Gosu::KbLeftShift], [Gosu::KbQ]


CTRL J+K+L
SHIFT,ALT Q

:control, 'J','K','L'
:shift,:alt, 'Q'
'escape'






SHIFT,ALT J+K+L
/(.*(,.*)*)\s*()/

# only serves to split into the first and second part
# can't seem to deal with the case where the first part is missing
/(.*(?:,.*)*)(?:\s)+(.*(?:\+.*)*)/


parts = input.split
# if parts.size == 1 # only main keys, no modifiers
# 	[
# 		parts[0].split('+')
# 	]
# elsif parts.size == 2
# 	[
# 		parts[0].split(','),
# 		parts[1].split('+')
# 	]
# end

output = Array.new
output << parts.pop.split('+')
output << parts.pop.split(',') unless parts.empty?
output.reverse






# Is the text interface really that important?
# Want to be able to specify based on keyboard position, not necessarily semantics
# Can you use the same input manager for an application as a game?
# Should you be able to specify something like "hit control" and mean either one of the keys?
	# Is that something for a higher level of abstraction?





# TODO: track end of events as well as their start. negative edge detection is expected for Action to work, so it should exist at this level as well.



# TODO: button IDs currently saved (inside the event) in string format. need to at least convert to int so that proper comparisons can be made with incoming button ID codes. This goes for both @keys and @modifiers. Not as simple as parsing the ints though, because it's not clear how the strings are specified.
# NOTE: remember that Ruby has named arguments now, so you could consider doing that instead of using hash arguments if you don't care about backwards compatibility.

# TODO: consider creating structure to enforce what keys are modifiers and what keys are "standard" keys. This would allow for the usage of keys typically used for input as accelerators, as long as they are not being currently used as standard keys, or vice versa (shift as a stand-alone key is more common for games, etc)

# TODO: add on structure to detect sequences
# TODO: think about how to make matches that are substrings of other matches more efficient. ex) double QFC+punch is a super. QFC+punch is hadouken. Hadouken is a substring of the super. Both are matches. Don't want to match Hadouken when you should be matching the super. But also want to consider that if you're getting one QFC, maybe you should prep for a second QFC because it might be a super in the pipe, instead of a Hadouken. May be totally unnecessary thought, though.
# TODO: consider using something other than regex lookup for sequences for efficiency (FSM is the most common choice. may want to delay until at least GUI library is up and runnig)

# TODO: consider using a better structure than a #each loop to find keyboard shorcuts. May not be worth the implementation time -> execution time tradeoff though, as explained by Jon Blow in his talk on how the data structures in Braid (as well as... Doom? Quake? something by ID) are pretty "horrible" in the sense that they're all linear. But they're super fast, so who cares.