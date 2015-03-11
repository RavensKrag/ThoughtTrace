module InputSystem


# sourced from tutorials:
# http://www.jstiles.com/Blog/How-To-Implement-Keyboard-Shortcuts-In-Your-Web-Application---Part-1
# http://www.jstiles.com/Blog/How-To-Implement-Keyboard-Shortcuts-in-Your-Web-Application---Part-2
# http://code.tutsplus.com/tutorials/detecting-key-combos-the-easy-way--active-8608
# plus some custom modifications to mesh up with the press-hold-release Action structure

class ButtonParser
	def initialize
		@active_keys = Set.new
		# may want to have two sets:
		# one for IDs and one for characters generated by the keys
		# so that you can specify inputs by code or by character as necessary
		
		
		@all_events = [] # hopefully this will be unnecessary
		
		@idle_events = Array.new
		@active_events = Array.new
	end
	
	
	
	
	
	def button_down(id)
		@active_keys.add id
		
		
		# pressed_events = self.press(id) + self.foo
		pressed_events = press(id)
		pressed_events.each{ |e| e.press }
		
		@active_events.concat pressed_events
	end
	
	def update
		@active_events.each do |event|
			event.hold
		end
	end
	
	def button_up(id)
		@active_keys.delete id
		
		
		released_events = release(id)
		released_events.each{ |e| e.release }
		
		@idle_events.concat released_events
	end
	
	# TODO: Move #press and #release calls inside respective methods for efficiency (less looping)
	
	
	
	
	
	private
	
	# handle combinations of keys with / without modifiers ex: (a+b shift,control) (x shift) (esc)
	def press(id)
		# NOTE: this implementation will execute all active combinations. not sure if more than one combination could be active during one press, but if that happens, things could get weird. Alternative would be to execute only the first match, but that would mean that the order in which events are declared would set an implicit priority.
		
		launched_events, @idle_events = 
			@idle_events.partition do |e|
				# check modifiers first, because that's probably a shorter list
				# makes for a faster short-circuit
				
				next unless all_mods_pressed(e)
				next unless all_keys_pressed(e)
				
				
				true # pseudo return
			end
		
		return launched_events
	end
	
	def release(id)
		released_events, @active_events = 
			@active_events.partition do |event|
				if event.keys.include? id or event.modifiers.include? id
					true # pseudo return
				end
			end
		
		return released_events
	end
	
	# TODO: Optimize: Consider using #delete_if to delete items, putting them in an array as you go. May be more efficient because you don't have to create an extra array.
	
	
	
	
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
	end
	
	public
	
	
	
	
	
	# TODO: register and rebind events under the new system of dual collections
	
	
	def register(event)
		# event must be idle if it's new
		@idle_events.push event
		
		return nil # prevent leakage
	end
	
	def unregister(event_name)
		# event could be idle, or active
		
		@idle_events.delete_if{ |event| event.name == event_name }
		@active_events.delete_if do |event|
			if event.name == event_name
				event.cancel # also, stop the event
				
				true # pseudo return
			end
		end
		
		return nil # prevent leakage
	end
	
	
	# TODO: try to merge #find and #unregister. Way too much code duplication right now.
	
	
	# Find is useful for extracting an event and the rebinding it
	# ex) @buttons.find(event_name).bind_to()
	def find(event_name)
		i = @idle_events.find_index{ |e| e.name == event_name }
		return @idle_events[i] if i
		
		
		i = @active_events.find_index{ |e| e.name == event_name }
		if i
			event = @active_events[i]
			event.cancel
			
			return event
		end
		
		
		return nil # nothing found if you've hit this point
	end
	
	
	
	private
	
	# NOTE: #subset? checks each element of self against the given set
	# TODO: Consider using arrays and (ary1 & ary2) to check subset. May be faster.
	
	def all_keys_pressed(event)
		event.keys.subset? @active_keys
	end
	
	def all_mods_pressed(event)
		event.modifiers.subset? @active_keys
			# all? will return true for an empty array
			# which is what you want in the case where no modifiers are listed
	end
end



end


# TODO: consider creating structure to enforce what keys are modifiers and what keys are "standard" keys. This would allow for the usage of keys typically used for input as accelerators, as long as they are not being currently used as standard keys, or vice versa (shift as a stand-alone key is more common for games, etc)

# TODO: add on structure to detect sequences
# TODO: think about how to make matches that are substrings of other matches more efficient. ex) double QFC+punch is a super. QFC+punch is hadouken. Hadouken is a substring of the super. Both are matches. Don't want to match Hadouken when you should be matching the super. But also want to consider that if you're getting one QFC, maybe you should prep for a second QFC because it might be a super in the pipe, instead of a Hadouken. May be totally unnecessary thought, though.
# TODO: consider using something other than regex lookup for sequences for efficiency (FSM is the most common choice. may want to delay until at least GUI library is up and runnig)

# TODO: consider using a better structure than a #each loop to find keyboard shorcuts. May not be worth the implementation time -> execution time tradeoff though, as explained by Jon Blow in his talk on how the data structures in Braid (as well as... Doom? Quake? something by ID) are pretty "horrible" in the sense that they're all linear. But they're super fast, so who cares.
