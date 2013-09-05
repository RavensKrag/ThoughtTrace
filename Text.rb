require 'yaml'

require './Serializable'

module TextSpace
	class Text
		MINIMUM_HEIGHT = 10
		CARET_WIDTH = 4
		@@default_font = nil # Must be set outside if a default font is to be used
		
		attr_accessor :position, :bb
		
		attr_accessor :color, :string, :box_visible
		
		def initialize(font=@@default_font)
			@font = font
			
			@height = 30
			
			@color = 0xffffffff
			@box_visible = false
			
			@position = CP::Vec2.new(0,0)
			
			@bb = CP::BB.new(0,0, 0,0)
			
			@active = false
			
			@caret_dt = 500 # in milliseconds
		end
		
		def update
			
		end
		
		def draw(z_index=0)
			string = if @active 
						$window.text_input.text
					else
						@string
					end
			
			
			update_bb(string)
			@font.draw string, @height, @position.x, @position.y, z_index, @color, @box_visible
			
			
			# Only draw caret if object is active
			if @active
				draw_caret(string, z_index) if caret_visible?
			end
		end
		
		def draw_caret(string, z_index)
			color = Gosu::Color::RED
			
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
			@color = 0xffff0000
		end
		
		def release
			@color = 0xffffffff
		end
		
		# TODO: Define mouse over and mouse out using state machine
		def mouse_over
			unless @mouse_over
				@mouse_over = true
				
				@box_visible = true
			end
		end
		
		def mouse_out
			if @mouse_over
				@mouse_over = false
				
				@box_visible = false
			end
		end
		
		def height
			@height
		end
		
		def height=(h)
			@height = h
			@height = MINIMUM_HEIGHT if @height < MINIMUM_HEIGHT
		end
		
		# Make this object the active text input
		def activate
			# Activate input stream
			@active = true
			
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
				percent = (mouse_x - x)/width.to_f
				i = (percent * (@string.length)).to_i
				
				
				$window.text_input.caret_pos = i
			end
		end
		
		# Stop editing the string based on keyboard input
		def deactivate
			@active = false
			
			@string = $window.text_input.text
			$window.text_input = nil
			
			$window.space.delete_if_empty self
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
		end
		
		private
		
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
	end
end