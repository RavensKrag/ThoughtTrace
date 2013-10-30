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

module MouseEvents
	class EventObject
		# must state key bindings as symbols, rather than variables
		# will scan the input system for a sequence with the given symbol as the name
		# (really just needs to be the same unique identifier as used for the sequence)
		
		# bind_to :left_click
		# pick_object_from :space
		
		attr_reader :name
		
		
		def initialize
			super() # needed for state_machine
			setup() # copy values from metaclass-instance properties
			
			# Set up event structure
			
			# may want to consider trying to refactor the code so initialization is unnecessary
			# this would allow for this to be declared as a mixin
			# which would be nice, because you should really not be able to create
			# instance of this class directly, as part of the interface is not implemented
			
			# @name = self.class.name.scan(/(.*)[Event]*/)[0][0].to_snake_case.to_sym
			# @name = self.class.name.to_snake_case.to_sym
			@name = self.class.name.split("::").last.to_snake_case.to_sym
			
			@binding = nil
		end
		
		def to_s
			@name
		end
		
		# def inspect
			
		# end
		
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
	
	
	#     __  ___     __                                    _____      __            
	#    /  |/  /__  / /_____ _____  _________  ____ _     / ___/___  / /___  ______ 
	#   / /|_/ / _ \/ __/ __ `/ __ \/ ___/ __ \/ __ `/     \__ \/ _ \/ __/ / / / __ \
	#  / /  / /  __/ /_/ /_/ / /_/ / /  / /_/ / /_/ /     ___/ /  __/ /_/ /_/ / /_/ /
	# /_/  /_/\___/\__/\__,_/ .___/_/   \____/\__, (_)   /____/\___/\__/\__,_/ .___/ 
	#                      /_/               /____/                         /_/      
	# Metacode to allow for defining class-level
		Foo = Struct.new(:value, :block)
		def self.meta_thingy(opt={})
			return @traits if opt.empty?
			
			
			data_name = opt[:read]
			
			metaclass.instance_eval do
				# ----- Write data -----
				define_method( opt[:write] ) do |val, &block|
					data = Foo.new
					data.value = val
					data.block = block
					
					@traits ||= Hash.new
					@traits[data_name] = data
				end
				
				# ----- Read data -----
				# read main value
					define_method opt[:read] do
						@traits[data_name].value
					end
				# read block
				if opt[:require_block]
					define_method "#{opt[:read]}_block" do
						@traits[data_name].block
					end
				end
			end
			
			
			
			
			
			# Copy class data into instance on initialization
			# Don't use the initialize method though,
			# because I don't want to deal with the other things that come with that method
			class_eval do
				define_method :setup do
					self.class.meta_thingy.each do |name, data|
						instance_variable_set("@#{name}", 		data.value)
						instance_variable_set("@#{name}_block",	data.block)
					end
				end
			end
		end
	
	#     _______              ______      ______               __       
	#    / ____(_)_______     / ____/___ _/ / / /_  ____ ______/ /_______
	#   / /_  / / ___/ _ \   / /   / __ `/ / / __ \/ __ `/ ___/ //_/ ___/
	#  / __/ / / /  /  __/  / /___/ /_/ / / / /_/ / /_/ / /__/ ,< (__  ) 
	# /_/   /_/_/   \___/   \____/\__,_/_/_/_.___/\__,_/\___/_/|_/____/  
		EVENT_TYPES.each do |event|
			# Fire callbacks
			define_method "#{event}_callback" do ||
				self.send event, @selection if self.respond_to? event
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
			# 	:pick_callback => @pick_type / nil # type of callback, not the actual block
			# 	:click => true / false
			# 	:drag => true / false
			# 	:release => true / false
			# }
			puts "#{self.class.name} --> id #{@binding.sequence_id}"
			output[:binding] = @binding.sequence_id
			
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
					
					puts "#{@name} --> #{a} :: #{b}"
					
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
		# figure out where to pick objects from
		meta_thingy	:write => :pick_object_from, :read => :pick_type,
					:require_block => true
		# limit the selection to the given domain
		# TODO: make selection domain apply to all picks, not just selection? (then limiting to a selection can become a layered option, rather than a completely separate pick mode)
		meta_thingy :write => :pick_selection_domain, :read => :pick_domain
		
		def pick_event
			# This callback should not fire when domain undefined
			return unless pick_callback_defined?
			
			picked = self.send("pick_from_#{@pick_type}")
			
			
			# --- (if defined callback does not fire)
			# is the a chance for callback to fire where no valid element is picked?
			# NO
			
			# valid insures callback executed?
			# essentially (unless there's no callback block defined)
			
			
			# Initial "if" wrap is necessary because the pick will not succeed in all cases.
			# If the pick fails, 
				# the block should not be run
				# @selection should not be set
			@selection =	if picked
								if @pick_type_block
									out = instance_exec picked, &@pick_type_block
									
									if @pick_type == :point
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
			return !!@pick_type
		end
		
		private
		
		# TODO: Consider if pick_from_? methods should really be private or not.
		# Don't see what good they would do at the MouseEvent level if exposed though.  There would have to be delegation from the Mouse level or something.
		def pick_from_space
			point = @mouse.position_in_world
			
			return @mouse.space.object_at point
		end
		
		# similar logic to picking from the world, but limit to a particular set of objects
		# put another way, perform the world query, but on a _different_ set of objects
		def pick_from_selection
			# Get the selection domain from method call.
			# Allows for easy and robust definition of what collection should be used
			
			raise "No selection to pick from." unless self.respond_to? @pick_domain
			
			
			selection = self.send @pick_domain
			point = @mouse.position_in_world
			
			return TextSpace::SelectionQueries.point_query(selection, point)
		end
		
		# TODO: consider putting block execution under these methods as well for clarity
		# TODO: consider using private nested class for greater clarity
		def pick_from_point
			point = @mouse.position_in_world
			object = @mouse.space.object_at point
			
			# add object generated as result of block to space automatically
			# this should remove the need to expose the space to mouse callbacks
			point if object == nil # only fire in empty space (else, don't fire query)
		end
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
