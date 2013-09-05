require 'state_machine'

module CP
	class Vec2
		def to_screen_space
			return self - $window.camera.offset
		end
		
		def to_world_space
			return self + $window.camera.offset
		end
	end
end

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
			# 	if obj.bb.contains_vect? position_in_world
			# 		obj.mouse_over
			# 	else
			# 		obj.mouse_out
			# 	end
			# end
			
			
			# Do not hover over multiple objects
			obj = $window.space.object_at position_in_world
			
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
		
		def world_position
			return CP::Vec2.new($window.mouse_x, $window.mouse_y).to_world_space
		end
		
		def screen_position
			return CP::Vec2.new($window.mouse_x, $window.mouse_y)
		end
		
		alias :position_in_world :world_position
		alias :position_in_world_coordinates :world_position
		
		alias :position_on_screen :screen_position
		alias :position_in_screen_coordinates :screen_position
		
		
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
						# preventing transition out of the "up" state
						# prevents click, drag, and release events from firing
						# by locking the state machine in the up state, where
						# the release event is stubbed,
						# and no callbacks are launched
						
						# only proceed if defined pick callbacks have fired
						a = @pick_object_callback_defined
						b = @pick_point_callback_defined
						c = pick_object_callback
						d = pick_point_callback
						
						# a b c d		out
						# 0 0 0 0		1	# both callbacks undefined
						# 0 0 0 1		1	# 
						# 0 0 1 0		1	# 
						# 0 0 1 1		1	# 
						# 0 1 0 0		0	# if only one callback defined, 
						# 0 1 0 1		1	# 
						# 0 1 1 0		0	# 
						# 0 1 1 1		1	# 
						# 1 0 0 0		0	# copy return of the defined callback
						# 1 0 0 1		0	# 
						# 1 0 1 0		1	# 
						# 1 0 1 1		1	# 
						# 1 1 0 0		0	# If both callbacks defined
						# 1 1 0 1		0	# then both must succeed before events can fire
						# 1 1 1 0		0	# (AND)
						# 1 1 1 1		1	# 
						
						if (!a || c) && (!b || d)
							click_callback
							
							button_down_event
						end
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
				@pick_object_callback_defined = true
				
				@pick_domain = domain
				@pick_callback = block
			end
			
			def pick_object_callback
				# This callback should not fire when domain undefined
				return unless @pick_object_callback_defined
				
				
				point = @mouse.position_in_world
				
				object = @mouse.space.object_at point
				
				picked = case @pick_domain
					when :space
						object
					when :selection
						object if selection.include? object
					when :point
						# add object generated as result of block to space automatically
						# this should remove the need to expose the space to mouse callbacks
						point if object == nil # only fire in empty space
					else
						raise "Invalid mouse picking domain (choose :point, :space, or :selection)"
				end
				
				
				# NOTE: This means selections are separate for each mouse event
				
				
				# --- (if defined callback does not fire)
				# is the a chance for callback to fire where no valid element is picked?
				# NO
				
				# valid insures callback executed?
				# essentially (unless there's no callback block defined)
				
				
				@selection =	if picked
									if @pick_callback
										out = @mouse.instance_exec picked, &@pick_callback
										
										if @pick_domain == :point
											@mouse.space << out
										end
										
										out
									else
										picked
									end
								else
									nil
								end
			end
			
			# TODO: Consider a different word than "pick" as object picking and point picking should both be allowed within the same event
			def pick_point_in(coordinate_space)
				@pick_point_callback_defined = true
				
				@point_coordinate_space = coordinate_space
			end
			
			def pick_point_callback
				return unless @pick_point_callback_defined
				
				vector = case @point_coordinate_space
					when :screen_space
						position_on_screen
					when :world_space
						position_in_world
					else
						raise "Invalid point callback coordinate space (should be either :screen_space or :world_space)"
				end
				
				# set value to be processed by other callbacks to be
				# a vector instead of a object in the space
				@point = vector
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
			
			# TODO: Remove this method.  Merge with Space#object_at
			def pick_from(selection, position)
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