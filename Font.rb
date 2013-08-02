# Allow for easy changes between different sizes of the same font face

module TextSpace
	class Font
		MINIMUM_HEIGHT = 5
		
		attr_reader :i
		attr_reader :name
		
		def initialize(window, name)
			@window = window
			@name = name
			
			@font_cache = []
			
			# TODO: Consider using some other sequence than Fibonacci. Just used fib because it was easy
			fib = ->(n) {
				return n if n < 2
				
				vals = [0, 1]
				(n-1+2).times do # extra two times because we're gonna take off the first two
					vals.push(vals[-1] + vals[-2]) 
				end
				
				# remove the first two values
				vals.shift
				vals.shift
				
				return vals
			}
			pow2 = ->(n) {
				vals = [1]
				(n-1).times do
					vals.push(vals[-1]*2)
				end
				
				return vals
			}
			
			# TODO: Consider removing font sizes < 5
			# Really small pixel size fonts aren't noticeably different, but the extra font objects will take up extra memory
			# Getting rid of < 5 will remove 1,2,3 == 3 items
			# Reduces number of fonts cached from 14 -> 11
			# That's about a 20% reduction
			heights = fib[14]
			# heights = pow2[11]
			# heights = [10,30,40]
			puts heights
			
			heights.each do |height|
				@font_cache << Gosu::Font.new(window, name, height)
			end
			
			@box_visible = true
			a = (0xff * 0.2).to_i
			c = 0x0000ff
			@box_color = (a << 24) | c
		end
		
		def draw(text, height, x,y,z=0, color=0xffffffff, box_visible=@box_visible)
			# --Prevent out of bounds
			height = MINIMUM_HEIGHT if height < MINIMUM_HEIGHT
			
			# ---Find the font in the cache
			f = find_font_object(height)
			
			# ---Calculate font scaling
			# @scale * font.height == @height
			scale = height / f.height.to_f
			
			
			f.draw(text, x,y,z, scale, scale, color)
			
			
			if box_visible
				width = f.text_width(text) * scale
				
				@window.draw_quad(
					x, y,	@box_color,
					x+width, y,	@box_color,
					x+width, y+height,	@box_color,
					x, y+height,	@box_color,
					z-1
				)
			end
		end
		
		def width(text, height)
			height = MINIMUM_HEIGHT if height < MINIMUM_HEIGHT
			
			f = find_font_object(height)
			scale = height / f.height.to_f
			
			return f.text_width(text) * scale
		end
		
		def hide_boxes_by_default
			@box_visible = false
		end
		
		def show_boxes_by_default
			@box_visible = true
		end
		
		private
		
		def find_font_object(height)
			i = @font_cache.index {|f| height <= f.height}
			i ||= @font_cache.size-1
			
			@window.debug_puts i
			
			return @font_cache[i]
		end
	end
end