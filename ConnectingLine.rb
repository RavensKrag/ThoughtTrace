module TextSpace
	# link together two objects with a line
	class ConnectingLine < Line
		def initialize(a, b, width, z=0, color=0xffffffff)
			@a = a
			@b = b
			
			@width = width
			@z = z
			@color = color
		end
		
		def update
			
		end
		
		def draw
			a_center = @a.bb.center
			b_center = @b.bb.center
			
			super(a_center, b_center, @width, @z, @color)
		end
	end
end