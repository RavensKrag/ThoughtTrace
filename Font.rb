# Allow for easy changes between different sizes of the same font face

module TextSpace
	class Font
		attr_reader :i
		
		def initialize(window, name)
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
			
			# TODO: Consider removing font sizes < 5
			# Really small pixel size fonts aren't noticeably different, but the extra font objects will take up extra memory
			# Getting rid of < 5 will remove 1,2,3 == 3 items
			# Reduces number of fonts cached from 14 -> 11
			# That's about a 20% reduction
			heights = fib[14]
			# puts heights
			
			
			heights.each do |height|
				@font_cache << Gosu::Font.new(window, name, height)
			end
			
			@i = 0
			@height = heights.first
			@scale = 1 # scaling to apply to cached font object to achieve desired size
		end
		
		def height=(h)
			# Allow any size of font
			# If the exact size is not present in the cache, find the closest one, and scale it
			@height = h
			
			# --Prevent out of bounds
			# No Upper
			# n/a
			# No Lower
			@height = 1 if @height < 1
			
			# Find the font in the cache
			@i = 0
			i = @font_cache.index {|f| h <= f.height}
			if i # only set if value found
				@i = i
			else
				# If the desired size is larger than the largest cached font,
				# just scale up the largest font
				@i = @font_cache.size-1
			end
			
			
			# @scale * font.height == @height
			@scale = @height / internal_font.height.to_f
		end
		
		def height
			@height
		end
		
		def debug_height
			internal_font.height * @scale
		end
		
		def draw(text, x,y,z, color=0xffffffff)
			internal_font.draw(text, x,y,z, @scale, @scale, color)
		end
		
		private
		
		def internal_font
			@font_cache[@i]
		end
	end
end