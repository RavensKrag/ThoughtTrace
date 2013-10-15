# taken from rails, courtesy of StackExchange
# http://stackoverflow.com/questions/1509915/converting-camel-case-to-underscore-case-in-ruby
class String
  # def underscore
  def to_snake_case
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end


module MouseEvents
	class EventObject
		# must state key bindings as symbols, rather than variables
		# will scan the input system for a sequence with the given symbol as the name
		# (really just needs to be the same unique identifier as used for the sequence)
		
		# bind_to :left_click
		# pick_object_from :space
		
		def initialize
			super() # needed for state_machine
			
			# Set up event structure
			
			# may want to consider trying to refactor the code so initialization is unnecessary
			# this would allow for this to be declared as a mixin
			# which would be nice, because you should really not be able to create
			# instance of this class directly, as part of the interface is not implemented
			
			@name = self.name.scan(/(.*)[Event]*/)[0][0].to_snake_case.to_sym
			
			@binding = nil
		end
		
		def add_to(mouse)
			@mouse = mouse
			bind(mouse.input_system)
			
			
			# set other variables here as well,
			# so events can be initialized without parameters
			# but all the events in the same handler can point to the same values
			@space = mouse.space
			
			@color = mouse.paint_box
		end
		
		# Do not define the callback methods, but expect that children of this class will
		# This is so you can tell which callbacks have been defined
		
		# def click(selected)
			
		# end
		
		# def drag(selected)
			
		# end
		
		# def release(selected)
			
		# end
		
		
		
		EVENT_TYPES = [:click, :drag, :release]
	
	
	#     ____  _           ___            
	#    / __ )(_)___  ____/ (_)___  ____ _
	#   / __  / / __ \/ __  / / __ \/ __ `/
	#  / /_/ / / / / / /_/ / / / / / /_/ / 
	# /_____/_/_/ /_/\__,_/_/_/ /_/\__, /  
	#                             /____/   
	# Establish "bind_to :left_click" and similar class-level definition
	# TOOD: Restructure to allow for rebinding
		# Set up binding to be used when the event is added to the mouse handeler
		class << self
			# NOTE: This structure does not allow for rebinding
			def bind_to(id)
				# define the binding, but do not set it
				
				# be careful with variable scope.  this is a class-level declaration
				@@binding_id = id
			end
			private :bind_to
		end
		
		def binding
			@binding.id
		end
		
		# Attach callbacks to input system
		def bind(input_system, id=@@binding_id)
			@binding.release if @binding # get rid of the old binding, if any
			@binding = Binding.new input_system, id
		end
		
		
		class Binding
			attr_reader :id
			
			def initialize(input_system, id)
				@input_system = input_system
				@id = id
				
				# check input system for a sequence with the requested identifier
				sequence = input_system[id]
				
				unless sequence raise "No sequence found"
				
				# set up new binding
				sequence.callbacks[id].tap do |c|
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
				
				
				# save reference to input sequence so that Binding can clean up after itself
				@input_sequence = sequence
			end
			
			# remove binding from input system
			def release
				@input_sequence.callbacks.delete @id
			end
			
			# serialize
			def dump(filepath)
				
			end
			
			# load from disk
			def self.load(filepath)
				
			end
		end
		private_constant :Binding # new in 1.9.3, so be aware of that
	
	
	#     _______              ______      ______               __       
	#    / ____(_)_______     / ____/___ _/ / / /_  ____ ______/ /_______
	#   / /_  / / ___/ _ \   / /   / __ `/ / / __ \/ __ `/ ___/ //_/ ___/
	#  / __/ / / /  /  __/  / /___/ /_/ / / / /_/ / /_/ / /__/ ,< (__  ) 
	# /_/   /_/_/   \___/   \____/\__,_/_/_/_.___/\__,_/\___/_/|_/____/  
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
	
	
	#    ______      _____      _           
	#   / ____/___  / / (_)____(_)___  ____ 
	#  / /   / __ \/ / / / ___/ / __ \/ __ \
	# / /___/ /_/ / / / (__  ) / /_/ / / / /
	# \____/\____/_/_/_/____/_/\____/_/ /_/ 
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
	
	
	#    _____ __        __     
	#   / ___// /_____ _/ /____ 
	#   \__ \/ __/ __ `/ __/ _ \
	#  ___/ / /_/ /_/ / /_/  __/
	# /____/\__/\__,_/\__/\___/ 
	# contains update method
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
					b = pick_event
					
					# a b		out
					# 0 0		1		# no pick necessary (callback undefined)
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
	
	
	#     ____  _      __      ______      ______               __       
	#    / __ \(_)____/ /__   / ____/___ _/ / / /_  ____ ______/ /_______
	#   / /_/ / / ___/ //_/  / /   / __ `/ / / __ \/ __ `/ ___/ //_/ ___/
	#  / ____/ / /__/ ,<    / /___/ /_/ / / / /_/ / /_/ / /__/ ,< (__  ) 
	# /_/   /_/\___/_/|_|   \____/\__,_/_/_/_.___/\__,_/\___/_/|_/____/  
	# Select object to be manipulated in further mouse callbacks
		def pick_object_from(domain, &block)
			@pick_domain = domain
			@pick_callback = block
		end
		
		def pick_event
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
		private :pick_from
	end
end

#     _   __                ______                 __     ____        __  __                
#    / | / /__ _      __   / ____/   _____  ____  / /_   / __ \____ _/ /_/ /____  _________ 
#   /  |/ / _ \ | /| / /  / __/ | | / / _ \/ __ \/ __/  / /_/ / __ `/ __/ __/ _ \/ ___/ __ \
#  / /|  /  __/ |/ |/ /  / /___ | |/ /  __/ / / / /_   / ____/ /_/ / /_/ /_/  __/ /  / / / /
# /_/ |_/\___/|__/|__/  /_____/ |___/\___/_/ /_/\__/  /_/    \__,_/\__/\__/\___/_/  /_/ /_/ 
	# module MouseEvents
	# 	class Test < MouseEvent
	# 		bind_to :left_click
	# 		pick_object_from :space
			
	# 		def initialize
	# 			super()
	# 		end
			
	# 		def click(selected)
				
	# 		end
			
	# 		def drag(selected)
				
	# 		end
			
	# 		def release(selected)
				
	# 		end
	# 	end
	# end
	
	
	# MouseEvents::Test.new





f_keys = (1..8).collect{ |i| "KbF#{i}".to_sym }.collect{ |s| Gosu.const_get(s) }
f_keys.each do |key|
	class_name = "change_color_to_swatch-#{key}"
	
	new_class =		Class.new(MouseEvent) do
						bind_to key
						
						pick_object_from :space
						
						def click(text)
							text.color = @paint_box[key]
						end
					end
	
	MouseEvents.const_set(class_name, new_class)
end




# class DeleteTextObjectEvent < MouseEvent
# 	bind_to :left_click
# 	pick_object_from :space
	
# 	def initialize
# 		super()
# 	end
	
# 	def click(selected)
		
# 	end
	
# 	def drag(selected)
		
# 	end
	
# 	def release(selected)
		
# 	end
# end

# class SelectSingleEvent < MouseEvent
# 	bind_to :left_click
# 	pick_object_from :space
	
# 	def initialize
# 		super()
# 	end
	
# 	def click(selected)
# 		# get object under cursor
# 		# add object to selection
		
# 		# save object so it can be de-selected later
# 	end
	
# 	def drag(selected)
		
# 	end
	
# 	def release(selected)
# 		# remove object from selection
# 	end
# end


# class SelectMultipleEvent < MouseEvent
# 	bind_to :left_click
# 	pick_object_from :space
	
# 	def initialize
# 		super()
# 	end
	
# 	def click(selected)
		
# 	end
	
# 	def drag(selected)
		
# 	end
	
# 	def release(selected)
		
# 	end
# end
