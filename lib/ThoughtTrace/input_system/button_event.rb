module InputSystem


class ButtonEvent
	attr_reader :name, :callbacks, :keys, :modifiers
	
	def initialize(name, callbacks)
		@name = name
		@callbacks = callbacks
		
		@keys = nil
		@modifiers = nil
	end
	
	# TODO: consider removing Binding class. It's kinda an unnecessary level of abstraction, now that we have the #bind_to interface.
	def bind_to(keys: [], modifiers: [])
		raise "Must specify at least one key" if keys.empty?
		
		@keys = keys.to_set
		@modifiers = modifiers.to_set
	end
			
	
	# just needs to provide #press #hold and #release
	# this class really exists as an example reference implementation
	# rather than something to be used or subclassed
	# TODO: Rename this class
	# TODO: Consider removing this class, and just noting the interface in documentation
	class EventCallback
		def initialize
			
		end
		
		def press
			
		end
		
		def hold
			
		end
		
		def release
			
		end
		
		def cancel
			
		end
	end
end



end


# TODO: Consider if @keys and @modifiers need to be Sets. Might be better to leave them as arrays. (Only because Set#subset? is implemented with a linear scan.)
# NOTE: currently using #include? in InputSystem#button_up to determine if chords have been invalidated.
# NOTE: Set linear scan may actually be faster. Hash#each seems faster than Array#each, for small data sets(hundreds or thousands), and only slightly slower for large data sets(millions).