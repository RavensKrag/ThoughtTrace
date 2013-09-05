require 'state_machine'

module TextSpace
	class MouseHandler
		attr_reader :space, :selection
		
		def initialize(space, selection, &block)
			super()
			
			@space = space
			@selection = selection
			
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
			obj = $window.space.object_at position_vector
			
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
		
		# Delegate down and up events to event callbacks
		[:button_down, :button_up].each do |button_event|
			define_method button_event do |id|
				@action_callbacks.each_value do |event_object|
					event_object.send button_event, id
				end
			end
		end
		
		def shutdown
			@selection.clear
		end
		
		def position_vector
			pos = CP::Vec2.new($window.mouse_x, $window.mouse_y)
			
			return pos + $window.camera.offset
		end
		
		
		
		
		# Interface to define callbacks
		def mouse_over(&block)
			@hover_callbacks[:mouse_over] = block
		end
		
		def mouse_out(&block)
			@hover_callbacks[:mouse_out] = block
		end
		
		def event(id, &block)
			@action_callbacks[id] = MouseEvent.new self, &block
		end
		
		
		private
		
		# Fire callbacks
		def mouse_over_callback
			instance_exec @hovered, @hover_callbacks[:mouse_over]
		end
		
		def mouse_out_callback
			instance_exec @hovered, @hover_callbacks[:mouse_out]
		end
		
		
		# Manage selection
		def select(obj)
			@selection.add obj
		end
		
		def deselect(obj)
			@selection.delete obj
		end
		
		def clear_selection
			@selection.clear
		end
		
		
		
		# Class to handle action callbacks
		# Delegate all the action-y bits to this,
		# only the hover events should be handled above
		class MouseEvent
			EVENT_TYPES = [:click, :drag, :release]
			
			def initialize(mouse_handler, &block)
				super()
				
				@mouse = mouse_handler
				
				@binding = nil # button id
				@callbacks = Hash.new
				
				instance_eval &block
			end
			
			# Should be able to compare the signatures of two ButtonEvent objects
			# to see if there will be any sort of collision of the event callbacks
			def signature
				output = ""
				
				EVENT_TYPES.each do |e|
					output << @callbacks[e] ? "1" : "0"
				end
			end
			
			def button_down(id)
				if id == @binding
					click_event
				end
			end
			
			def button_up(id)
				if id == @binding
					release_event
				end
			end
			
			state_machine :state, :initial => :up do
				state :up do
					def update
						
					end
					
					def click_event
						pick_object_callback
						pick_point_callback
						
						click_callback
						
						button_down_event
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
						
						
						button_up_event
					end
				end
				
				
				event :button_down_event do
					transition :up => :down
				end
				
				event :button_up_event do
					transition :down => :up
				end
			end
			
			
			
			# Select object to be manipulated in further mouse callbacks
			def pick_object_from(domain, &block)
				@pick_domain = domain
				@pick_callback = block
			end
			
			def pick_object_callback
				return unless @pick_domain # This callback should not fire when domain undefined
				
				picked = case @pick_domain
					when :point
						position_vector
					when :space
						# pick_from @space.objects
						@mouse.space.object_at @mouse.position_vector
					when :selection
						pick_from @selection
					else
						raise "Invalid mouse picking domain (choose :point, :space, or :selection)"
				end
				
				# NOTE: This means selections are separate for each mouse event
				@selection =	if @pick_callback
									@mouse.instance_exec picked, &@pick_callback
								else
									picked
								end
			end
			
			def pick_point_in(coordinate_space)
				@point_coordinate_space = coordinate_space
			end
			
			def pick_point_callback
				vector = case @point_coordinate_space
					when :screen_space
						CP::Vec2.new($window.mouse_x, $window.mouse_y)
					when :world_space
						position_vector
				end
				
				# set value to be processed by other callbacks to be
				# a vector instead of a object in the space
			end
			
			EVENT_TYPES.each do |event|
				# Fire callbacks
				define_method "#{event}_callback" do ||
					if @callbacks[event]
						@mouse.instance_exec @mouse.space, @selection, &@callbacks[event]
					end
				end
				
				# Interface to define callbacks
				define_method event do |&block|
					@callbacks[event] = block
				end
			end
			
			# Manage button binding
			def bind_to(button)
				# TODO: Take ControlBinding instead of just a button ID
				@binding = button
			end
			
			def binding
				@binding
			end
			
			alias :binding= :bind_to
			
			
			private
			
			def pick_from(selection)
				# TODO: This method should belong to a selection class
				# arguably the selection code should belong to the selection,
				# as would be oop style
				# that means that any partition of the space (including the whole space)
				# needs to be considered a selection
				
				
				
				# Select objects under the mouse
				# If there's a conflict, get smallest one (least area)
				
				# There should be some other rule about distance to center of object
					# triggers for many objects of similar size?
					
					# when objects are densely packed, it can be hard to select the right one
					# the intuitive approach is to try to select dense objects by their center
				selection = selection.select do |o|
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
		
		
		
		# # Return all objects the mouse is on top of
		# def hovered
			
		# end
		
		# # Return the most recent object the mouse is on top of
		
		
		# # Return the most relevant object the mouse is on top of
		# # (ie, highest priority for selection)
	end
end