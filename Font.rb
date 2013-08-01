# Allow for easy changes between different sizes of the same font face

module TextSpace
	class Font
		def initialize(window, name)
			@font_cache = []
			
			heights = [10, 30, 40]
			heights.each do |height|
				@font_cache << Gosu::Font.new(window, name, height)
			end
			
			@i = 0
			@height = heights.first
		end
		
		def height=(s)
			@i = s
			
			# --Prevent out of bounds
			# No Upper
			@i = @font_cache.size-1 if @i >= @font_cache.size
			# No Lower
			@i = 0 if @i < 0
			
			# Allow any size of font
			# If the exact size is not present in the cache, find the closest one, and scale it
			
		end
		
		def height
			@i
		end
		
		def draw(*args)
			@font_cache[@i].draw(*args)
		end
	end
end