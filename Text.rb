require 'yaml'

require './Serializable'

module CP
	class Vec2
		include TextSpace::Serializable
		
		def init_with coder
			args = YAML.load(coder.scalar)
			initialize(*args)
		end

		def to_string_representation
			[self.x, self.y].to_yaml
		end
		
		class << self
			def from_string_representation(string_representation)
				args = YAML.load(string_representation)
				new(*args)
			end
		end
	end
	
	class BB
		include TextSpace::Serializable
		
		def init_with coder
			args = YAML.load(coder.scalar)
			initialize(*args)
		end

		def to_string_representation
			[self.l, self.b, self.r, self.t].to_yaml
		end
		
		class << self
			def from_string_representation(string_representation)
				args = YAML.load(string_representation)
				new(*args)
			end
		end
	end
end


module TextSpace
	class Text
		MINIMUM_HEIGHT = 10
		CARET_WIDTH = 4
		
		attr_accessor :position, :bb
		
		attr_accessor :color, :string, :box_visible
		
		def initialize(font)
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
			# don't really need this, because nil has a truth value of false, so !nil == true
			# @caret_visible ||= false
			
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
			@active = true
			
			$window.text_input = Gosu::TextInput.new
			$window.text_input.text = @string
		end
		
		# Stop editing the string based on keyboard input
		def deactivate
			@active = false
			
			@string = $window.text_input.text
			$window.text_input = nil
			
			$window.space.delete self unless @string
		end
		
		def dump(filepath)
			# Save only necessary data
			
			data = {
				:font => @font.name,
				:height => @height,
				:color => @color,
				:box_visible => @box_visible,
				:position => [@position.x, @position.y],
				
				:string => @string
			}
			
			File.open(filepath, "w") do |f|
				f.puts YAML::dump(data)
			end
		end
		
		class << self
			def load(font, filepath)
				data = YAML::load_file(filepath)
				
				t = Text.new font
				
				t.height = data[:height]
				t.color = data[:color]
				t.box_visible = data[:box_visible]
				t.position = CP::Vec2.new(data[:position][0], data[:position][1])
				
				t.string = data[:string]
				
				return t
			end
		end
		
		def to_s
			@string
		end
		
		def inspect
			"#{@font.inspect} : #{@string}"
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