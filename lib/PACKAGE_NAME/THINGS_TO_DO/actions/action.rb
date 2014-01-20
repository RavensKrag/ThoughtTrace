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

require 'state_machine'

module TextSpace
	class Action
		# bind_to :left_click
		# pick_object_from :space
		
		def initialize
			super() # needed for state_machine
			
			# Set up event structure
			
			# may want to consider trying to refactor the code so initialization is unnecessary
			# this would allow for this to be declared as a mixin
			# which would be nice, because you should really not be able to create
			# instance of this class directly, as part of the interface is not implemented
		end
		
		# def inspect
			
		# end
		
		# TODO: consider just passing all the values in to Action separately. (that could be messy, though)
		# TODO: Make sure classes delegate to #add_to as necessary
		def add_to(mouse)
			@mouse = mouse
			
			
			# set other variables here as well,
			# so events can be initialized without parameters
			# but all the events in the same handler can point to the same values
			# @space = mouse.space
			@color = mouse.paint_box
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
		def collide_with(other, fields_to_check=([:pick_callback] + EVENT_TYPES))
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
			# 	:pick_callback => @pick_type / nil # type of callback, not the actual block
			# 	:click => true / false
			# 	:drag => true / false
			# 	:release => true / false
			# }
			
			# NOTE: Actions don't track bindings, so that part of the collision is no longer here
			
			output[:pick_callback] = @pick_type if pick_callback_defined?
			
			# check what sorts of events this event object can process
			EVENT_TYPES.each do |e|
				output[e] = self.respond_to? e
			end
			
			
			return output
		end
	
	
	#    _____ __        __     
	#   / ___// /_____ _/ /____ 
	#   \__ \/ __/ __ `/ __/ _ \
	#  ___/ / /_/ /_/ / /_/  __/
	# /____/\__/\__,_/\__/\___/ 
	# contains update method
		state_machine :state, :initial => :idle do
			state :idle do
				def update
					
				end
			end
			
			state :holding do
				def update
					hold_callback
				end
			end
			
			
			
			
			
			event :press_event do
				transition :idle => :holding
			end
			
			event :release_event do
				transition :holding => :idle
			end
			
			event :cancel_event do
				transition any => :idle
			end
		end
		
		
		
		def press(arg)
			# run press events this way so that the argument can be passed to the press callback
			
			
			press_event
			
			# only fire callback if transition successful
			press_callback arg if self.state_name == :holding
		end
		# WARNING: This does not account for times when #press event should not fire. ex, when the state machine is in the :holding state (ie, has already been pressed)
		
		# Need to make press event private so press can only occur through this interface.
		# Apparently can't do that in the expected manner, which is annoying
		# private :press_event
		
		
		def release
			# run release events this way so that the return value of the release callback can be exposed to the outside world
			
			
			release_event
			
			release_callback if self.state_name == :idle
		end
		# private :release_event
		
		
		# Reset the Action.
		# NOTE: All actions should define specific versions of #cancel which reset things specific to that action.
		def cancel
			cancel_event
		end
		
		
		# NOTE: The #pick interface is not defined in this file, as not all actions require it.
		# Still, here's the specification:
		# * returns true when pick succeeds, and false otherwise
		# * If the pick is successful, #pick should automatically call #press
		# 	(this way, you only have to call #pick, and not both #pick and #press)
		
		
		# Callbacks
		private
		
		
		# [:press, :hold, :release].each do |event|
			
		# 	define_method "#{event}_callback" do
		# 		callback_name = "on_#{event}"
		# 		self.send callback_name if self.respond_to? callback_name
		# 	end
			
		# end
		
		
		
		
		# press callback is different from the rest,
		# because it sends the input parameter
		# def press_callback(obj)
		# 	event = :press
		# 	callback_name = "on_#{event}"
		# 	self.send callback_name, obj if self.respond_to? callback_name
		# end
		
		# def hold_callback
		# 	event = :hold
		# 	callback_name = "on_#{event}"
		# 	self.send callback_name if self.respond_to? callback_name
		# end
		
		# def release_callback
		# 	event = :release
		# 	callback_name = "on_#{event}"
		# 	self.send callback_name if self.respond_to? callback_name
		# end
		
		
		
		
		
		
		# Unfortunately, this method of checking if the method exists every time it's called
		# means that 
		
		# Unfortunately, this means that the system much check on each callback,
		# whether or not the appropriate method is defined.
		# Might want to just look up on initialization once?
			# That might mess with weird singleton method definition,
			# but that's kinda weird magic anyway...
		
		def press_callback(obj)
			# puts "press -- #{self.class} -- #{self.respond_to?(:on_press)}"
			# puts "PUBLIC"
			# p self.methods
			# puts "PRIVATE"
			# p self.private_methods
			
			on_press(obj) if self.private_methods.include?(:on_press)
		end
		
		def hold_callback
			on_hold if self.private_methods.include?(:on_hold)
		end
		
		def release_callback
			on_release if self.private_methods.include?(:on_release)
		end
		
		
		
		
		
		
		
		
		
		
		# EVENT_TYPES = [:press, :hold, :release]
		# EVENT_TYPES.each do |event|
		# 	# define_method "#{event}_callback" do
		# 	# 	callback_name = "on_#{event}"
		# 	# 	self.send callback_name if self.respond_to? callback_name
		# 	# end
			
			
			
		# 	params = "obj" if event == :press
		# 	send_args = ", #{params}" if params
			
			
		# 	code =	<<-eos
		# 		    	def #{event}_callback(#{params})
		# 					callback_name = "on_#{event}"
		# 					self.send callback_name #{send_args} if self.respond_to? callback_name
		# 				end
		# 			eos
			
		# 	eval code
		# end
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
			
	# 		def on_press(selected)
				
	# 		end
			
	# 		def on_hold(selected)
				
	# 		end
			
	# 		def on_release(selected)
				
	# 		end
	# 	end
	# end
	
	
	# MouseEvents::Test.new





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
