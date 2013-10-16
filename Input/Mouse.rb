require 'state_machine'

module InputManager
	class MouseHandler
		attr_reader :input_system, :space, :selection, :paint_box
		attr_reader :event_handlers
		
		NullMouseOver = Struct.new(:mouse_in, :mouse_out)
		
		def initialize(input_system, space, selection, paint_box)
			super()
			
			@input_system = input_system
			@space = space
			@selection = selection
			@paint_box = paint_box
			
			@hover_callbacks = Hash.new # callback name => callback
			
			@event_handlers = Array.new # list of MouseEvents::EventObject descendants
			
			
			# @callbacks = Hash.new # trigger => callback
			
			
			@hovered = nil
			@last_hovered_object = NullMouseOver.new
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
			obj = @space.object_at position_in_world
			
			if obj
				if obj != @last_hovered_object
					# Moved to new object
					@last_hovered_object.mouse_out
					
					obj.mouse_over
				end
			else
				# Moved into empty space
				@last_hovered_object.mouse_out
			end
			
			@last_hovered_object = obj || NullMouseOver.new
			
			
			
			@event_handlers.each do |event|
				event.update
			end
		end
				
		def shutdown
			@selection.clear
			@last_hovered_object.mouse_out
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
		
		
		def add(*events)
			events.each do |new_event|
				# sets up necessary variables, does not commit changes to system
				new_event.add_to self
				
				# check system against this new addition
				id = new_event.name
				
				@event_handlers.each do |old_event|
					event_name = old_event.name
					
					# puts "old sig: #{event_name} --- new sig: #{id}"
					puts "\ncompare: #{id} to #{event_name}"
					
					# TODO: Consider removing :release from collision test
					# should still show if release callbacks overlap,
					# but :release should not be a deciding factor
					# 
					# ex)	[:click, :release] collides with [:click]
					# 		because release is ignored
					collision = new_event.collide_with old_event
					
					if collision
						raise "Event #{id} collides with #{event_name} in fields #{collision}"
					end
				end
				
				
				
				@event_handlers << new_event
			end
		end
		
		
		# Manage selection
			# should consider not having this delegation at all
			# now that these methods must be public
		def select(obj)
			@selection.add obj
		end
		
		def deselect(obj)
			@selection.delete obj
		end
		
		def clear_selection
			@selection.clear
		end
		
		
		private
		
		# Fire callbacks
		def mouse_over_callback
			instance_exec @hovered, @hover_callbacks[:mouse_over]
		end
		
		def mouse_out_callback
			instance_exec @hovered, @hover_callbacks[:mouse_out]
		end
		
		
		
		
		# # Return all objects the mouse is on top of
		# def hovered
			
		# end
		
		# # Return the most recent object the mouse is on top of
		
		
		# # Return the most relevant object the mouse is on top of
		# # (ie, highest priority for selection)
	end
end