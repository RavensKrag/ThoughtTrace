require 'yaml'

require './Serializable'

module CP
	class Vec2
		include TextSpace::Serializable
		
		def init_with coder
			# split = coder.scalar.split ":"
			# initialize(:hours => split[0], :minutes => split[1], :seconds => split[2])
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
			# split = coder.scalar.split ":"
			# initialize(:hours => split[0], :minutes => split[1], :seconds => split[2])
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
		
		attr_accessor :position, :bb
		
		attr_accessor :color, :string, :box_visible
		
		def initialize(font)
			@font = font
			
			@height = 30
			
			@color = 0xffffffff
			@box_visible = false
			
			@position = CP::Vec2.new(0,0)
			
			@bb = CP::BB.new(0,0, 0,0)
		end
		
		def update
			
		end
		
		def draw(z_index=0)
			update_bb(@string)
			@font.draw @string, @height, @position.x, @position.y, z_index, @color, @box_visible
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