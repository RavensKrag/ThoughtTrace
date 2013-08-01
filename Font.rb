# Allow for easy changes between different sizes of the same font face

module TextSpace
	class Font
		def initialize(window, name)
			@font_cache = []
			[10, 30, 40].each do |size|
				@font_cache << Gosu::Font.new(window, name, size)
			end
			
			@i = 0
		end
		
		def size=(s)
			@i = s
			
			# --Prevent out of bounds
			# No Upper
			@i = @font_cache.size-1 if @i >= @font_cache.size
			# No Lower
			@i = 0 if @i < 0
		end
		
		def size
			@i
		end
		
		def draw(*args)
			@font_cache[@i].draw(*args)
		end
	end
end