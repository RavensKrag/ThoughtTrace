require 'yaml'

require 'state_machine'
require './serialization/serializable'

module TextSpace
	class Text
		MINIMUM_HEIGHT = 10
		CARET_WIDTH = 4
		
		attr_accessor :color, :string, :box_visible, :box_color
		
		attr_reader :font
		
		attr_reader :physics
		
		def initialize(font)
			super()
			
			@font = font
			
			@height = 30
			
			@color = Gosu::Color.argb(0xffFFFFFF)
			
			@box_visible = false
			@box_color = Gosu::Color.argb(((0xff * 0.2).to_i << (8*3)) | 0x0000ff)
			
			
			
			
						body = CP::Body.new(Float::INFINITY, Float::INFINITY) 
						shape = CP::Shape::Poly.new body, new_geometry(), CP::Vec2.new(0,0)
			@physics = TextSpace::Component::Physics.new(self, body, shape)
			
			
			
			dt = 500 # in milliseconds
			@caret = Caret.new(CARET_WIDTH, Gosu::Color.argb(0xff8E68A4), dt)
		end
		
		def update
			
		end
		
		def draw(z_index=0)
			string = if active?
						$window.text_input.text
					else
						@string
					end
			
			
			recompute_geometry
			
			
			@font.draw	string, @height, @physics.body.p.x, @physics.body.p.y, z_index, @color
			@physics.draw @box_color, z_index-1 if @box_visible
			
			# Only draw caret if object is active
			if active?
				@caret.draw(self, z_index)
			end
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
			
			
			
			event :mouse_over do
				transition :out => :in
			end
			
				# after_transition :out => :in, :do => :enable_hover_style
			
			
			event :mouse_out do
				transition :in => :out
			end
			
				# after_transition :in => :out, :do => :remove_hover_style
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
			x = @physics.body.p.x
			mouse_x = $window.input.mouse.position_in_world.x
			
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
			"#<TextSpace::Text:{string => \"#{@string}\" font => #{@font.inspect}}>"
		end
		
		private
		
		def activation
			# enable_active_style
			
			$window.text_input = Gosu::TextInput.new
			$window.text_input.text = @string
			
			unless @string == nil || @string.empty?
				# Move caret into position
				# Try to get as close to the position of the cursor as possible
				width = @font.width(@string, @height)
				x = @physics.body.p.x
				mouse_x = $window.input.mouse.position_in_world.x
				
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
			# remove_active_style
			
			@string = $window.text_input.text
			
			$window.text_input = nil
			
			$window.space.delete_if_empty self # gc component, essentially
		end
		
		# Dump contents of input buffer into @string if this object is connected to input buffer
		def dump_string_buffer
			@string = $window.text_input.text if active?
		end
		
		
		def recompute_geometry
			@physics.shape.set_verts! new_geometry, CP::Vec2.new(0,0)
		end
		
		def new_geometry
			l = 0
			b = 0
			r = @font.width(string, @height)
			t = @height
			
			verts = [
				CP::Vec2.new(l, t),
				CP::Vec2.new(r, t),
				CP::Vec2.new(r, b),
				CP::Vec2.new(l, b)
			]
			
			raise "Problem with specified verts." unless CP::Shape::Poly.valid? verts
			
			return verts
		end
		
		
		
		class Caret
			# In order to create the flickering caret effect,
			# caret displays on for a time interval equal to dt,
			# and then is hidden for a time equal to dt
			def initialize(width, color, dt)
				@dt = dt
				
				@visible = true
				
				@line = TextSpace::Line.new(width, color)
			end
			
			def update
				
			end
			
			def draw(text, z_index)
				if visible?
					position = text.physics.body.p
					height = text.height
					
					
					p0 = position.clone
					# p1 = CP::Vec2.new(x_offset+position.x, position.y+height)
					p1 = p0 + CP::Vec2.new(0, height)
					
					
					offset = text.character_offset($window.text_input.caret_pos)
					@line.draw(p0 + offset, p1 + offset, z_index)
				end
			end
			
			def visible?
				@timestamp ||= Gosu.milliseconds
				# Insure previous timestamp never goes over current time
				# Needed for serialization, as well as to guard against timer rollover
				@timestamp = Gosu.milliseconds if @timestamp > Gosu.milliseconds
				
				dt = Gosu.milliseconds - @timestamp
				
				if dt >= @dt
					@visible = !@visible
					
					@timestamp = Gosu.milliseconds
				end
				
				return @visible
			end
		end
		private_constant :Caret
	end
end