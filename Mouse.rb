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
			
			
			
			EVENT_TYPES.each do |event|
				# Fire callbacks
				define_method "#{event}_callback" do ||
					if @callbacks[event]
						@mouse.instance_exec @mouse.space, &@callbacks[event] 
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
		end
		
		
		
		# # Return all objects the mouse is on top of
		# def hovered
			
		# end
		
		# # Return the most recent object the mouse is on top of
		
		
		# # Return the most relevant object the mouse is on top of
		# # (ie, highest priority for selection)
	end
end