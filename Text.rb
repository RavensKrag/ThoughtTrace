module TextSpace
	class Text
		MINIMUM_HEIGHT = 10
		
		attr_accessor :position, :bb
		
		attr_accessor :string
		
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
		
		def draw(text, z_index)
			update_bb(text)
			@font.draw text, @height, @position.x, @position.y, z_index, @color, @box_visible
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