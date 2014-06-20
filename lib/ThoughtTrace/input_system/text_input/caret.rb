module ThoughtTrace


class TextInput
	class Caret
		attr_reader :width, :height # mutators defined manually
		attr_reader :position       # mutators defined manually
		
		def initialize(width)
			@width = width
			
			# some default height, doesn't really matter
			# the "real" height should always be set before the Caret is actually used
			@height = 10
			
			@position = CP::Vec2.new(0,0)
			
			
			
			@verts = create_geometry @width, @height
			
			@dt = 800
			@visible = true
		end
		
		# control flashing of caret
		# TODO: only flash when caret is not being moved
		def update
			# if caret has been moved recently, don't blink
			# otherwise, blink based on which of two time phases is active
			
			
			if @dirty
				# has been modified recently
				timestamp = @dirty
				dt = Gosu.milliseconds - timestamp
				# puts "#{Gosu.milliseconds}  -> #{dt}"
				
				# clear dirty flag if enough time has elapsed
				# (should be able to use the same @dt as with standard flickering)
				@dirty = nil if dt > @dt
				
				
				
				@visible = true
			else
				# divide time into 2 phases, where each phase has length @dt
				if Gosu.milliseconds % (@dt*2) < @dt
					@visible = true
				else
					@visible = false
				end
			end
		end
		
		# render the caret
		def draw(color, z=0)
			if @visible
				$window.translate @position.x,@position.y do
					$window.draw_quad	@verts[0].x, @verts[0].y, color,
										@verts[1].x, @verts[1].y, color,
										@verts[2].x, @verts[2].y, color,
										@verts[3].x, @verts[3].y, color,
										z
				end
			end
		end
		
		
		def width=(w)
			@width = w
			@verts = create_geometry @width, @height 
		end
		
		def height=(h)
			@height = h
			@verts = create_geometry @width, @height
		end
		
		def position=(pos)
			@dirty = Gosu.milliseconds
			@position = pos
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