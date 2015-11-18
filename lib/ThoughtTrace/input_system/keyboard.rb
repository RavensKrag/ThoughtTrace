module InputSystem


class Keyboard
	def initialize(window)
		@window = window
		
		# this could be useful in other parts of the input system
		# regardless, it's good do declare all bindings to lower-level input symbols at this level
		@accelerators = InputSystem::AcceleratorParser.new(
							window,
							:shift   => [Gosu::KbLeftShift,   Gosu::KbRightShift],
							:control => [Gosu::KbLeftControl, Gosu::KbRightControl],
							:alt     => [Gosu::KbLeftAlt,     Gosu::KbRightAlt]
						)
	end
	
	def update
		
	end
	
	def active_accelerators
		@accelerators.active_accelerators
	end
end



end
