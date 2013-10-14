require 'state_machine'

module InputManager
	class MouseHandler
		attr_reader :space, :selection
		attr_reader :action_callbacks
		
		NullMouseOver = Struct.new(:mouse_in, :mouse_out)
		
		def initialize(space, selection, paint_box, &block)
			super()
			
			@space = space
			@selection = selection
			@paint_box = paint_box
			
			@hover_callbacks = Hash.new # callback name => callback
			
			@action_callbacks = Hash.new # input_binding => callback
			
			
			# @callbacks = Hash.new # trigger => callback
			
			
			@hovered = nil
			@last_hovered_object = NullMouseOver.new
			
			
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
			
			
			
			@action_callbacks.each_value do |callback|
				callback.update
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
		
		def event(id, &block)
			new_event = MouseEvent.new self, id, &block
			
			@action_callbacks.each do |event_name, old_event|
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
					# raise "Event #{id} collides with #{event_name} in fields #{collision}"
				end
			end
			
			@action_callbacks[id] = new_event
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
			
			def initialize(mouse_handler, name, &block)
				super()
				
				@mouse = mouse_handler
				@name = name
				
				@binding = nil # input binding
				@callbacks = Hash.new
				
				instance_eval &block
			end
			
			# Evaluate collision between this object and other
			# 
			# iterate through properties trying to disambiguate
			# if you hit the end of properties list, and callback still ambiguous,
			# collision has occurred
			def collide_with(other, fields_to_check=([:binding, :pick_callback] + EVENT_TYPES))
				# property must be defined on both sides
				# if it's only defined on one side, then it's not a collision,
				# (should be able to disambiguate by difference)
				other_sig = other.signature
				sig = self.signature
				
				colliding_fields = Array.new
				
				collision_occured = fields_to_check.all? do |property|
					puts property
					
					value = sig[property]
					other_value = other_sig[property]
					
					if other_value && value
						# --- property defined on both sides ---
						
						# possibility of collision
						
						# collision if one or more of the properties which are defined on both sides are set to equivalent values
						
						# General case
						if other_value == value
							puts "=== collide ==="
							
							colliding_fields << property
							
							true
						else
							# Special cases
							if( 
							property == :pick_callback and
								# Space picking collides with selection picking
								(other_value == :space && value == :selection or
								value == :space && other_value == :selection)
							)
								# NOTE: Could return a tuple and say "priority to :selection"
								# or ":priority => :selection"
								# would have to change the whole return type system of this method though
								puts "=== collide (special case) ==="
								
								colliding_fields << property
								
								true
							else
								# Special cases have failed, so no collision detected
								puts "--- different (#{value} vs #{other_value})"
								
								false
							end
						end
					elsif !!other_value ^ !!value
						# --- only defined on one side or the other ---
						
						# no collision
						puts "+++ different (signature mismatch)"
						return false # short circuit
					else
						# --- triggers when both are undefined ---
						
						# continue to check for collision
						puts ">>> continue"
						
						true
					end
				end
				
				
				# Return collision result
				if collision_occured
					if colliding_fields.empty?
						return nil
					else
						return colliding_fields
					end
				else
					return false
				end
			end
			
			# Should be able to compare the signatures of two ButtonEvent objects
			# to see if there will be any sort of collision of the event callbacks
			# TODO: Consider only implementing equality tests, and not having #signature
			def signature
				output = Hash.new
				# {
				# 	:binding => @binding / nil
				# 	:pick_callback => @pick_domain / nil # type of callback, not the actual block
				# 	:click => true / false
				# 	:drag => true / false
				# 	:release => true / false
				# }
				
				output[:binding] = @binding
				
				output[:pick_callback] = @pick_domain if @pick_object_callback_defined
				
				EVENT_TYPES.each do |e|
					output[e] = @callbacks[e] ? true : false
				end
				
				
				return output
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
						a = pick_callback_defined?
						b = pick_object_callback
						
						# a b		out
						# 0 0		1		# callback undefined
						# 0 1		1		# 
						# 1 0		0		# if it's defined, it must have fired properly
						# 1 1		1		# 
						
						if (!a || b)
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
				@pick_domain = domain
				@pick_callback = block
			end
			
			def pick_object_callback
				# This callback should not fire when domain undefined
				return unless pick_callback_defined?
				
				
				point = @mouse.position_in_world
				
				object = @mouse.space.object_at point
				
				picked = case @pick_domain
					when :space
						object
					when :selection
						# object if selection.include? object
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
			
			def pick_callback_defined?
				# return truthyness
				return !!@pick_domain
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
			
			
			# TODO: make sure bindings can be defined in an interface on Mouse, but that event firing is handled by the input system
			
			
			# Manage button binding
			def bind_to(binding)
				# remove previous binding, if any
				@binding.callbacks.delete @name if @binding
				
				# set up new binding
				@binding = binding
				
				
				# should just use the name of the mouse event,
				# that way you don't have to define two names
				@binding.callbacks[@name].tap do |c|
					c.on_press do
						click_event
					end
					
					c.on_hold do
						
					end
					
					c.on_release do
						release_event
					end
					
					# c.on_idle do
						# hover?
					# end
				end
			end
			alias :binding= :bind_to
			
			
			def binding
				@binding
			end
			
			
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