module TextSpace
	class MouseEvent
		attr_reader :button
		
		def initialize(button)
			@button = button
		end
		
		event_types = [:click, :release, :drag, :mouse_over, :mouse_out]
		
		attr_reader *event_types
		
		event_types.each do |method|
			define_method "#{method}_callback" do |&block|
				puts @click, @release, @drag
				instance_variable_set "@#{method}", block
			end
		end
	end
end