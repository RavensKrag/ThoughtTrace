module ThoughtTrace
	module Events


# NOTE: Events don't need to deal with Memento objects. That's an additional constraint imposed by Action. button events are more general than that
class PressButton
	def initialize()
		
	end
	
	def press
		@action = @callback.call
		@action.press
	end
	
	def hold
		@action.hold
	end
	
	def release
		@action.release
		@finishing_callback.call(@action)
		
		@action = nil
	end
	
	def cancel
		@action.cancel
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