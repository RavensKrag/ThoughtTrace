# Allow for easy changes between different sizes of the same font face

module TextSpace
	class Font
		attr_reader :i
		
		def initialize(window, name)
			@font_cache = []
			
			heights = [10, 30, 40]
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