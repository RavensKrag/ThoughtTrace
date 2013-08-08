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
		attr_reader :selected, :mouse_down_location
		
		MouseData = Struct.new(:event_thing, :mouse_down_location, :selected)
		
		def initialize(button)
			super()
			
			@button = button
		end
		
		def add_button(event_thing)
			@buttons ||= Hash.new
			
			@buttons[event_thing.button] = MouseData.new(event_thing)
		end
		
		def button_down(id)
			click_event(@buttons[id]) if @buttons[id]
		end
		
		def button_up(id)
			release_event(@buttons[id]) if @buttons[id]
		end
		
		state_machine :state, :initial => :clicking do
			state :clicking do
				def update
					# Mouse over and mouse out
					
					# Hover over all objects under the mouse
					# $window.objects.each do |obj|
					# 	if obj.bb.contains_vect? $window.mouse_position_vector
					# 		obj.mouse_over
					# 	else
					# 		obj.mouse_out
					# 	end
					# end
					
					
					# Do not hover over multiple objects
					obj = object_at_point $window.mouse_position_vector
					
					@last_hovered_object.mouse_out if @last_hovered_object
					@last_hovered_object = obj
					
					if obj
						@last_hovered_object.mouse_over
					end
				end
				
				def click_event(mouse_data)
					mouse_data.mouse_down_location = $window.mouse_position_vector
					obj = object_at_point mouse_data.mouse_down_location
					
					
					
					
					if obj
						# Click on object
						mouse_data.selected = obj
						
						instance_eval do
							mouse_data.event_thing.click.call(mouse_data)
						end
					else
						# Clicked empty space
						mouse_data.selected = $window.spawn_new_text
					end
					
					mouse_data.selected.click
					
					click
				end
				
				def release_event(mouse_data)
					
				end
			end
			
			
			state :dragging do
				def update
					@buttons.each do |button_id, mouse_data|
						if mouse_data.event_thing.drag
							mouse_data.event_thing.drag.call(mouse_data) if mouse_data.selected
						end
					end
				end
				
				def click_event(mouse_data)
					
				end
				
				def release_event(mouse_data)
					instance_eval do
						mouse_data.event_thing.release.call(mouse_data)
					end
					
					mouse_data.selected.release
					mouse_data.selected = nil
					
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
		
		private
		
		# TODO: Should probably move this into some sort of "space" class, as a point query
		def object_at_point(position)
			# Select objects under the mouse
			# If there's a conflict, get smallest one (least area)
			
			# There should be some other rule about distance to center of object
				# triggers for many objects of similar size?
				
				# when objects are densely packed, it can be hard to select the right one
				# the intuitive approach is to try to select dense objects by their center
			selection = $window.objects.select do |o|
				o.bb.contains_vect? position
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
				distance_to_a = a.bb.center.dist position
				distance_to_b = b.bb.center.dist position
				
				# Listed in order of precedence, but sort order needs to be reverse of that
				[a.bb.area, distance_to_a].reverse <=> [b.bb.area, distance_to_b].reverse
			end
			
			return selection.first
		end
	end
end