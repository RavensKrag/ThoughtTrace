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
		attr_reader :selection
		
		def initialize(&block)
			super()
			
			@bindings = Hash.new # button => callback name
			@hover_callbacks = Hash.new # callback name => callback
			
			@action_callbacks = Hash.new # button => callback
			
			
			# @callbacks = Hash.new # trigger => callback
			
			
			@hovered = nil
			
			
			instance_eval &block
		end
		
		def update
			# Mouse over and mouse out
			
			# Hover over all objects under the mouse
			# $window.objects.each do |obj|
			# 	if obj.bb.contains_vect? position_vector
			# 		obj.mouse_over
			# 	else
			# 		obj.mouse_out
			# 	end
			# end
			
			
			# Do not hover over multiple objects
			obj = object_at_point position_vector
			
			if @last_hovered_object
				# mouse_data.event_thing.mouse_out.call
				
				@last_hovered_object.mouse_out
			end
			@last_hovered_object = obj
			
			if obj
				# mouse_data.event_thing.mouse_over.call
				
				@last_hovered_object.mouse_over
			end
			
			@action_callbacks.each_value do |callback|
				callback.update
			end
		end
		
		def button_down(id)
			if @action_callbacks.has_key? id
				@action_callbacks[id].button_down
			end
		end
		
		def button_up(id)
			if @action_callbacks.has_key? id
				@action_callbacks[id].button_up
			end
		end
		
		def position_vector
			CP::Vec2.new($window.mouse_x, $window.mouse_y)
		end
		
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
		
		
		
		
		
		private
		
		# Interface to define callbacks
		def on_mouse_over(&block)
			@hover_callbacks[:mouse_over] = block
		end
		
		def on_mouse_out(&block)
			@hover_callbacks[:mouse_out] = block
		end
		
		def button(id, &block)
			@action_callbacks[id] = ButtonEvent.new self, &block
		end
		
		
		# Fire callbacks
		def mouse_over_callback
			instance_exec @hovered, @hover_callbacks[:mouse_over]
		end
		
		def mouse_out_callback
			instance_exec @hovered, @hover_callbacks[:mouse_out]
		end
		
		
		
		
		
		# Class to handle action callbacks
		# Delegate all the action-y bits to this,
		# only the hover events should be handled above
		class ButtonEvent
			def initialize(mouse_handler, &block)
				super()
				
				@mouse = mouse_handler
				
				@callbacks = Hash.new
				
				instance_eval &block
			end
			
			def button_down
				click_event
			end
			
			def button_up
				release_event
			end
			
			state_machine :state, :initial => :up do
				state :up do
					def update
						
					end
					
					def click_event
						@mouse_down_vector = @mouse.position_vector
						
						click_callback
						
						
						click
					end
					
					def release_event
						
					end
				end
				
				state :down do
					def update
						drag_callback
					end
					
					def click_event
						
					end
					
					def release_event
						release_callback
						
						
						release
					end
				end
				
				before_transition :down => any do
					@mouse_down_vector = nil
				end
				
				
				
				event :click do
					transition :up => :down
				end
				
				event :release do
					transition :down => :up
				end
			end
			
			
			
			[:click, :release, :drag].each do |event|
			# ----------
			
			# Fire callbacks
			define_method "#{event}_callback" do ||
				@mouse.instance_exec @mouse_down_vector, &@callbacks[event]
			end
			
			
			
			# Interface to define callbacks
			private
			define_method "on_#{event}" do |&block|
				@callbacks[event] = block
			end
			
			# ----------
			end
			
		end
		
		# # Return all objects the mouse is on top of
		# def hovered
			
		# end
		
		# # Return the most recent object the mouse is on top of
		
		
		# # Return the most relevant object the mouse is on top of
		# # (ie, highest priority for selection)
	end
end