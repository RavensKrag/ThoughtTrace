module ThoughtTrace
	module Events


# NOTE: Events don't need to deal with Memento objects. That's an additional constraint imposed by Action. button events are more general than that
class LinkStyles
	def initialize(selection, action_factory)
		@selection = selection
		@action_factory = action_factory
		
		@zero = CP::Vec2.new(0,0)
	end
	
	def press(event_name)
		return if @selection.empty?
		
		@link_action = @action_factory.create(@selection, :link_styles)
		@link_action.press(@zero)
	end
	
	def hold(event_name)
		@link_action.hold(@zero)    if @link_action
	end
	
	def release(event_name)
		@link_action.release(@zero) if @link_action
	end
	
	def cancel(event_name)
		@link_action.cancel         if @link_action
	end
end



end
end