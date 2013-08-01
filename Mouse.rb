require 'state_machine'

module TextSpace
	class MouseHandler
		def initialize(window, button)
			super()
			
			@window = window
			@button = button
			
			@selected = nil
			@mouse_down_location = nil # CP::Vec2.new(0,0)
		end
		
		
		def button_down(id)
			click_event if id == @button
		end
		
		def button_up(id)
			release_event if id == @button
		end
		
		def mouse_position_vector
			CP::Vec2.new(@window.mouse_x, @window.mouse_y)
		end
		
		state_machine :state, :initial => :clicking do
			state :clicking do
				def update
					
				end
				
				def click_event
					@mouse_down_location = mouse_position_vector
					
					if @window.text.bb.contains_vect? @mouse_down_location
						@selected = @window.text
						
						@original_position = @selected.position
						@selected.click
						
						click
					end
				end
				
				def release_event
					
				end
			end
			
			
			state :dragging do
				def update
					mouse_delta = mouse_position_vector - @mouse_down_location
					
					if @selected
						p = @original_position + mouse_delta
						@selected.position = p
					end
				end
				
				def click_event
					
				end
				
				def release_event
					@selected.release
					release
				end
			end
			
			before_transition :dragging => any do
				@mouse_down_location = nil
				@selected = nil
			end
			
			
			
			event :click do
				transition :clicking => :dragging
			end
			
			event :release do
				transition :dragging => :clicking
			end
		end
	end
end