module ThoughtTrace


class TextInput
	class Caret
		attr_reader :width, :height # mutators defined manually
		attr_accessor :position
		
		def initialize(width)
			@width = width
			
			# some default height, doesn't really matter
			# the "real" height should always be set before the Caret is actually used
			@height = 10
			
			@position = CP::Vec2.new(0,0)
			
			
			
			@verts = create_geometry @width, @height
		end
		
		# control flashing of caret
		def update
			
		end
		
		# render the caret
		def draw(color, z=0)
			# TODO: use GPU transform instead of manually calculating translation
			verts = @verts.collect{ |v|  v + @position }
			
			$window.draw_quad	verts[0].x, verts[0].y, color,
								verts[1].x, verts[1].y, color,
								verts[2].x, verts[2].y, color,
								verts[3].x, verts[3].y, color,
								z
		end
		
		
		def width=(w)
			@width = w
			@verts = create_geometry @width, @height 
		end
		
		def height=(h)
			@height = h
			@verts = create_geometry @width, @height
		end
		
		
		
		
		
		
		private
		
		def create_geometry(w,h)
			verts = [
				CP::Vec2.new(0,0),
				CP::Vec2.new(w,0),
				CP::Vec2.new(w,h),
				CP::Vec2.new(0,h)
			]
			verts.each{ |v|  v.x -= w/2 }
		end
	end
end



end