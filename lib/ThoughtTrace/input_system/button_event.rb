module InputSystem


class ButtonEvent
	attr_reader :name, :keys, :modifiers
	
	def initialize(name, callbacks)
		@name = name
		@callbacks = callbacks # provides these methods: initialize, press, hold, release, cancel
		
		@keys = nil
		@modifiers = nil
	end
	
	# TODO: consider removing Binding class. It's kinda an unnecessary level of abstraction, now that we have the #bind_to interface.
	def bind_to(keys: [], modifiers: [])
		raise "Must specify at least one key" if keys.empty?
		
		@keys = keys.to_set
		@modifiers = modifiers.to_set
	end
	
	
	# extend Forwardable
	# def_delegators :@callbacks, :press, :hold, :release, :cancel
	
	def press
		@callbacks.press
	end
	
	def hold
		@callbacks.hold
	end
	
	def release
		@callbacks.release
	end
	
	def cancel
		@callbacks.cancel
	end
end



end


# TODO: Consider if @keys and @modifiers need to be Sets. Might be better to leave them as arrays. (Only because Set#subset? is implemented with a linear scan.)
	# NOTE: currently using #include? in InputSystem#button_up to determine if chords have been invalidated.
	# NOTE: Set linear scan may actually be faster. Hash#each seems faster than Array#each, for small data sets(hundreds or thousands), and only slightly slower for large data sets(millions).

# TODO: consider if ButtonEvent should really be a private class under ButtonParser and how that would even work. (This basically means that ButtonEvent is only useful as a wrapper for data that ButtonParser works with. This statement is pretty true, but I'm not sure if that would make for a worse interface, or a better one.)