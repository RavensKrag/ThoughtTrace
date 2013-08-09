module TextSpace
	class MouseEvent
		attr_reader :button
		
		def initialize(button, &block)
			@button = button
			
			instance_eval &block
		end
		
		event_types = [:click, :release, :drag, :mouse_over, :mouse_out]
		
		attr_reader *event_types
		
		private
		
		event_types.each do |method|
			define_method "on_#{method}" do |&block|
				puts @click, @release, @drag
				instance_variable_set "@#{method}", block
			end
		end
	end
end