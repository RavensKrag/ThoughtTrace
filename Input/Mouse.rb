module InputManager
	class MouseHandler
		attr_reader :space, :selection, :paint_box
		
		NullMouseOver = Struct.new(:mouse_in, :mouse_out)
		
		def initialize(space, selection, paint_box)
			super()
			
			@space = space
			@selection = selection
			@paint_box = paint_box
			
			@hover_callbacks = Hash.new # callback name => callback
			
			
			# @callbacks = Hash.new # trigger => callback
			
			
			@hovered = nil
			@last_hovered_object = NullMouseOver.new
		end
		
		def add(*events)
			
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
		# TODO: input_id should be optional.  should default to selecting a null object.
		def bind(action_group, input_system, binding_hash)
			binding_hash.each do |action_name, input_id|
				action = action_group[action_name]
				raise "No action found with the name #{action_name}" unless action
				
				input = input_system[input_id]
				raise "No input sequence found with the ID #{input_id}" unless input 
				
				
				
				@bindings ||= Hash.new
				
				# get rid of the old binding, if any
				old_binding = @bindings[action.class]
				old_binding.release if old_binding
				
				# set up new binding
				action.add_to self # TODO: should probably have a means to remove from mouse
				binding = Binding.new self, action, input
				
				# test_binding_for_collision(binding)
				# collision_with_existing?(binding)
					# collision occurs when actions that can not be disambiguated
					# are bound to the same input
				
				@bindings[action.class] = binding
			end
		end
		
		def binding(action_name)
			@bindings[action_name].sequence_id
		end
		
		private
		
		# return true if the given binding collides with any existing bindings
		def collision_with_existing?(binding)
			@bindings.each do |bound_action_name, existing_binding|
				# see if the actions are mapped to the same input
				# if they are, you need to disambiguate
				# if can not disambiguate, then it's a collision
				
				
				# no binding overlap; no need to try to disambiguate
				return false unless binding.input == existing_binding.input
				
				
				overlapping_properties = binding.action.collide_with existing_binding.action
				
				if overlapping_properties
					raise "Action #{binding.action.class} collides with #{existing_binding.action.class} in fields #{collision}"
				end
			end
		end
		
		
		
		
		# TODO: should probably though exception outside this method, just because it makes the main flow of #bind clearer.  The current implementation does not make it clear that the collision test contains an exception flow.
		def test_binding_for_collision
			# most of the old code to test for collision is in what is now the Action.rb file
			# this is kinda weird, because Actions are no longer responsible
			# for input bindings
			# even though input bindings are critical in detecting collisions
			# (are they really though?)
			
			
			
			# directly copied from old #add method
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
				
				
				
				# @event_handlers << new_event
			end
		end
		
		public
		
		
		class Binding
			attr_reader :action, :input
			
			# TODO: Re-order parameter list, or similar touchup.  This is kinda weird.
			def initialize(mouse, action, input)
				@mouse = mouse
				
				@action = action
				@input = input
				
				
				
				# set up new binding
				@input.callbacks[@action].tap do |c|
					c.on_press do
						if @action.respond_to? :pick
							@action.pick(@mouse.position_in_world)
						else
							@action.press
						end
					end
					
					# c.on_hold do
						
					# end
					
					c.on_release do
						@action.release
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