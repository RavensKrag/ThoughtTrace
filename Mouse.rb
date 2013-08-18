require 'state_machine'

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
		
		def shutdown
			if @selection
				@selection.release
				@selection.deactivate
				
				@selection = nil
			end
		end
		
		def position_vector
			pos = CP::Vec2.new($window.mouse_x, $window.mouse_y)
			
			return pos + $window.camera.offset
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