module TextSpace
	class Text
		attr_accessor :position, :height
		
		def initialize(font)
			@font = font
			
			@position = CP::Vec2.new(0,0)
			@height = 1
		end
		
		def update
			
		end
		
		def draw(text, z_index, color=0xffffffff)
			@font.draw text, @height, @position.x, @position.y, z_index, color
		end
	end
end