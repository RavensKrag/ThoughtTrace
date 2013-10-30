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
		
		
	#     __  ___                                              ______                 __      
	#    /  |/  /___  __  __________  ____ _   _____  _____   / ____/   _____  ____  / /______
	#   / /|_/ / __ \/ / / / ___/ _ \/ __ \ | / / _ \/ ___/  / __/ | | / / _ \/ __ \/ __/ ___/
	#  / /  / / /_/ / /_/ (__  )  __/ /_/ / |/ /  __/ /     / /___ | |/ /  __/ / / / /_(__  ) 
	# /_/  /_/\____/\__,_/____/\___/\____/|___/\___/_/     /_____/ |___/\___/_/ /_/\__/____/  
		# Interface to define callbacks
		def mouse_over(&block)
			@hover_callbacks[:mouse_over] = block
		end
		
		def mouse_out(&block)
			@hover_callbacks[:mouse_out] = block
		end
		
		private
		
		# Fire callbacks
		def mouse_over_callback
			instance_exec @hovered, @hover_callbacks[:mouse_over]
		end
		
		def mouse_out_callback
			instance_exec @hovered, @hover_callbacks[:mouse_out]
		end
		
		public
		
		
	#     ____  _           ___            
	#    / __ )(_)___  ____/ (_)___  ____ _
	#   / __  / / __ \/ __  / / __ \/ __ `/
	#  / /_/ / / / / / /_/ / / / / / /_/ / 
	# /_____/_/_/ /_/\__,_/_/_/ /_/\__, /  
	#                             /____/   
	# set up bindings to fire events as defined by Action classes
		# TODO: consider passing in the input object itself, instead of just the ID.  Would allow the user to decide how they want to manage input objects.
		# TODO: input_id should be optional.  should default to selecting a null object.
		def bind(action_group, input_system, binding_hash)
			binding_hash.each do |action_name, input_id|
				action = action_group[action_name]
				raise "No action found with that name" unless action
				
				input = input_system[input_id]
				raise "No input sequence found with that ID" unless input 
				
				
				
				# get rid of the old binding, if any
				old_binding = @bindings[action]
				old_binding.release if old_binding
				
				# set up new binding
				@bindings[action] = Binding.new action, input
			end
		end
		
		
		# TODO: consider getting bindings based on binding name, instead of a pointer to the actual binding object
			# If you change how the bindings are accessed, must change the keys to the @bindings hash to match.
		def binding(action)
			@bindings[action].sequence_id
		end
		
		
		class Binding
			attr_reader :action, :input
			
			# TODO: Re-order parameter list, or similar touchup.  This is kinda weird.
			def initialize(action, input)
				@action = action
				@input = input
				
				
				
				# set up new binding
				@input.callbacks[@action].tap do |c|
					c.on_press do
						@action.click_event
					end
					
					# c.on_hold do
						
					# end
					
					c.on_release do
						@action.release_event
					end
				end
			end
			
			# remove binding from input system
			def release
				@input.callbacks.delete @action
			end
			
			# serialize
			def dump(filepath)
				
			end
			
			# load from disk
			def self.load(filepath)
				
			end
		
		end
		private_constant :Binding # new in 1.9.3, so be aware of that
	end
end