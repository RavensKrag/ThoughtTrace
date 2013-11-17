require 'yaml'

require './Serializable'
require 'state_machine'

module TextSpace
	class Text
		MINIMUM_HEIGHT = 10
		CARET_WIDTH = 4
		
		@@default_font = nil # Must be set outside if a default font is to be used
		@@paint_box = nil # Must be set before any text objects are created
		
		attr_accessor :position, :bb
		
		attr_accessor :color, :string, :box_visible, :box_color
		
		attr_reader :font
		
		def initialize(font=@@default_font)
			super()
			
			raise "Must set default font" unless @@default_font
			raise "Must set paint box object for color selection" unless @@paint_box
			
			@font = font
			
			@height = 30
			
			@active_color = @@paint_box[:active]
			@default_color = @@paint_box[:default_font]
			@color = @default_color
			
			@box_visible = false
			@box_color = @@paint_box[:text_background]
			
			@position = CP::Vec2.new(0,0)
			
			@bb = CP::BB.new(0,0, 0,0)
			
			@caret_dt = 500 # in milliseconds
		end
		
		def update
			
		end
		
		def draw(z_index=0)
			string = if active?
						$window.text_input.text
					else
						@string
					end
			
			
			update_bb(string)
			@font.draw	string, @height, @position.x, @position.y, z_index, @color
			@bb.draw @box_color, z_index-1 if @box_visible
			
			
			# Only draw caret if object is active
			if active?
				draw_caret(string, z_index) if caret_visible?
			end
		end
		
		def draw_caret(string, z_index)
			color = @@paint_box[:text_caret]
			
			x_offset = 	if $window.text_input.caret_pos == 0
							0
						else
							@font.width(string[0..$window.text_input.caret_pos-1], @height)
						end
			
			
			$window.draw_quad	x_offset+@position.x-CARET_WIDTH/2, @position.y, color,
								x_offset+@position.x+CARET_WIDTH/2, @position.y, color,
								x_offset+@position.x-CARET_WIDTH/2, @position.y+@height, color,
								x_offset+@position.x+CARET_WIDTH/2, @position.y+@height, color,
								z_index
		end
		
		def caret_visible?
			@caret_visible = true if @caret_visible == nil # initialize caret visibility
			
			@caret_timestamp ||= Gosu.milliseconds
			# Insure previous timestamp never goes over current time
			# Needed for serialization, as well as to guard against timer rollover
			@caret_timestamp = Gosu.milliseconds if @caret_timestamp > Gosu.milliseconds
			
			dt = Gosu.milliseconds - @caret_timestamp
			
			if dt >= @caret_dt
				@caret_visible = !@caret_visible
				
				@caret_timestamp = Gosu.milliseconds
			end
			
			return @caret_visible
		end
		
		def click
			
		end
		
		def release
			
		end
		
		def hide_bb
			@box_visible = false
		end
		
		def show_bb
			@box_visible = true
		end
		
		state_machine :mouseover_status, :initial => :out do
			state :in do
				
			end
			
			state :out do
				
			end
			
			
			after_transition :out => :in do |text|
				text.enable_hover_style
			end
			
			after_transition :in => :out do |text|
				text.remove_hover_style
			end
			
			
			event :mouse_over do
				transition :out => :in
			end
			
			event :mouse_out do
				transition :in => :out
			end
		end
		
		state_machine :acquire_input_stream, :initial => :inactive do
			state :active do
				
			end
			
			state :inactive do
				
			end
			
			
			event :activate do
				transition :inactive => :active
			end
			
			event :deactivate do
				transition :active => :inactive
			end
			
			
			after_transition :inactive => :active, :do => :activation
			after_transition :active => :inactive, :do => :deactivation
		end
		
		state_machine :style, :initial => :default, :namespace => 'style' do
			state :default do
				
			end
			
			state :active do
				
			end
			
			state :hover do
				
			end
			
			
			after_transition any => :default do |text|
				text.box_color = TextSpace::Text.paint_box[:text_background]
				text.hide_bb
				
				# text.color = TextSpace::Text.paint_box[:default_font]
			end
			
			after_transition any => :active do |text|
				text.box_color = TextSpace::Text.paint_box[:active]
				text.show_bb
				
				# text.color = TextSpace::Text.paint_box[:active]
			end
			
			after_transition any => :hover do |text|
				text.box_color = TextSpace::Text.paint_box[:text_background]
				text.show_bb
				
				# text.color = TextSpace::Text.paint_box[:default_font]
			end
			
			
			event :enable_hover do
				transition any - :active => :hover
			end
			
			event :remove_hover do
				transition :hover => :default
			end
			
			event :enable_active do
				transition any => :active
			end
			
			event :remove_active do
				transition :active => :default
			end
		end
		
		def height
			@height
		end
		
		def height=(h)
			@height = h
			@height = MINIMUM_HEIGHT if @height < MINIMUM_HEIGHT
		end
		
		# Given a position in world space, return the character index of the closest character
		# similar logic as in #activate to figure out where to put the caret
		def closest_character_index(position)
			# NOTE: Always dump input buffer to string (if buffer connected to this object) before performing operations on @string.
			dump_string_buffer
			
			
			# Move caret into position
			# Try to get as close to the position of the cursor as possible
			width = @font.width(@string, @height)
			x = @position.x
			mouse_x = $window.mouse.position_in_world.x
			
			# Figure out where mouse_x is along the continuum from x to x+width
			# Use that to guess what the closest letter is
			# * basically, this algorithm is assuming fixed width, but it works pretty well
			percent = (mouse_x - x)/width.to_f
			i = (percent * (@string.length)).to_i
			
			i = 0 if i < 0
			i = @string.length if i > @string.length
			
			return i
		end
		
		def character_offset(i)
			dump_string_buffer
			
			
			x = 0
			y = 0
			
			
			
			x =	if i == 0
					0
				else
					@font.width(@string[0..(i-1)], @height)
				end
			
			return CP::Vec2.new(x,y)
		end
		
		def to_s
			@string
		end
		
		def inspect
			"#{@font.inspect} : #{@string}"
		end
		
		class << self
			def default_font
				return @@default_font
			end
			
			def default_font=(font)
				@@default_font = font
			end
			
			def paint_box
				return @@paint_box
			end
			
			def paint_box=(font)
				@@paint_box = font
			end
		end
		
		private
		
		def activation
			enable_active_style
			
			$window.text_input = Gosu::TextInput.new
			$window.text_input.text = @string
			
			unless @string == nil || @string.empty?
				# Move caret into position
				# Try to get as close to the position of the cursor as possible
				width = @font.width(@string, @height)
				x = @position.x
				mouse_x = $window.mouse.position_in_world.x
				
				# Figure out where mouse_x is along the continuum from x to x+width
				# Use that to guess what the closest letter is
				# * basically, this algorithm is assuming fixed width, but it works pretty well
				# TODO: Use more accurate caret positioning algorithm. Caret being off contributes fairly significantly to program feel.
				percent = (mouse_x - x)/width.to_f
				i = (percent * (@string.length)).to_i
				
				
				$window.text_input.caret_pos = i
			end
		end
		
		def deactivation
			remove_active_style
			
			@string = $window.text_input.text
			
			$window.text_input = nil
			
			$window.space.delete_if_empty self # gc component, essentially
		end
		
		def update_bb(string)
			@bb.l = 0
			@bb.b = 0
			@bb.r = @font.width(string, @height)
			@bb.t = @height
			
			@bb.l += @position.x
			@bb.r += @position.x
			@bb.t += @position.y
			@bb.b += @position.y
		end
		
		# Dump contents of input buffer into @string if this object is connected to input buffer
		def dump_string_buffer
			@string = $window.text_input.text if active?
		end
	end
end