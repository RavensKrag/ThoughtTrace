require 'state_machine'

module CP
	class BB
		def area
			(self.r - self.l) * (self.t - self.b)
		end
		
		def center
			CP::Vec2.new(self.l+width/2, self.b+height/2)
		end
		
		def height
			self.t - self.b
		end
		
		def width
			self.r - self.l
		end
	end
end

module TextSpace
	class MouseHandler
		attr_reader :selected
		
		def initialize(button)
			super()
			
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
			CP::Vec2.new($window.mouse_x, $window.mouse_y)
		end
		
		state_machine :state, :initial => :clicking do
			state :clicking do
				def update
					# Mouse over and mouse out
					
					$window.objects.each do |obj|
						if obj.bb.contains_vect? mouse_position_vector
							obj.mouse_over
						else
							obj.mouse_out
						end
					end
				end
				
				def click_event
					@mouse_down_location = mouse_position_vector
					
					# Select objects under the mouse
					# If there's a conflict, get smallest one (least area)
					
					# There should be some other rule about distance to center of object
						# triggers for many objects of similar size?
						
						# when objects are densely packed, it can be hard to select the right one
						# the intuitive approach is to try to select dense objects by their center
					selection = $window.objects.select do |o|
						o.bb.contains_vect? @mouse_down_location
					end
					
					selection.sort! do |a, b|
						a.bb.area <=> b.bb.area
					end
					
					# Get the smallest area values, within a certain threshold
					# Results in a certain margin of what size is acceptable,
					# relative to the smallest object
					selection = selection.select do |o|
						# TODO: Tweak margin
						size_margin = 1.8 # percentage
						
						first_area = selection.first.bb.area
						o.bb.area.between? first_area, first_area*(size_margin)
					end
					
					selection.sort! do |a, b|
						distance_to_a = a.bb.center.dist @mouse_down_location
						distance_to_b = b.bb.center.dist @mouse_down_location
						
						# Listed in order of precedence, but sort order needs to be reverse of that
						[a.bb.area, distance_to_a].reverse <=> [b.bb.area, distance_to_b].reverse
					end
					
					
					obj = selection.first
										
					
					if obj
						# Click on object
						@selected = obj
					else
						# Clicked empty space
						@selected = $window.spawn_new_text
					end
					
					@original_position = @selected.position
					@selected.click
					
					click
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