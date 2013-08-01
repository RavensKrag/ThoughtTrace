module TextSpace
	class Text
		attr_accessor :height
		attr_accessor :position, :bb
		
		attr_accessor :string
		
		def initialize(font)
			@font = font
			
			@height = 1
			
			@color = 0xffffffff
			
			@position = CP::Vec2.new(0,0)
			
			@bb = CP::BB.new(0,0, 0,0)
		end
		
		def update
			
		end
		
		def draw(text, z_index)
			update_bb(text)
			@font.draw text, @height, @position.x, @position.y, z_index, @color
		end
		
		def click
			
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