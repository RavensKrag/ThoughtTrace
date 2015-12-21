module ThoughtTrace
	module Events


# NOTE: Events don't need to deal with Memento objects. That's an additional constraint imposed by Action. button events are more general than that
class PressButton
	def initialize()
		@zero = CP::Vec2.new(0,0)
	end
	
	def press
		@action = @callback.call
		@action.press(@zero)
	end
	
	def hold
		@action.hold(@zero)
	end
	
	def release
		@action.release(@zero)
		@finishing_callback.call(@action)
		
		@action = nil
	end
	
	def cancel
		@action.cancel(@zero)
	end
	
	
	
	
	def set_callback(&block)
		@callback = block
	end
	
	def set_finishing_callback(&block)
		@finishing_callback = block
	end
end



end
end