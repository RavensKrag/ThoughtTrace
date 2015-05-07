module ThoughtTrace


class TextInput
	class Caret < ThoughtTrace::Rectangle
		attr_accessor :color, :dt
		
		def initialize(width)
			# some default height, doesn't really matter
			# the "real" height should always be set before the Caret is actually used
			height = 10
			
			super(width, height)
			
			@components[:style].edit(:default) do |s|
				s[:color] = Gosu::Color.argb(0xffaaaaaa)
			end
			
			
			
			@dt = 800
			@visible = true
		end
		
		# control flashing of caret
		def update
			puts "update"
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
		def draw(z_index=0)
			super(z_index) if @visible
		end
		
		
		def width=(w)
			w = w.round
			return if w == self.width
			puts "change width"
			p = self.position
			
			@components[:physics].shape.resize!(
				CP::Vec2.new(1,0), :local_space, point:CP::Vec2.new(w,0), lock_aspect:false	
			)
			
			self.position = p
		end
		
		def height=(h)
			h = h.round
			return if h == self.height
			puts "change height"
			p = self.position
			
			@components[:physics].shape.resize!(
				CP::Vec2.new(0,1), :local_space, point:CP::Vec2.new(0,h), lock_aspect:false	
			)
			
			self.position = p
		end
		
		# height and width methods similar to Text entity
		def height
			@components[:physics].shape.height.round
		end
		
		def width
			@components[:physics].shape.width.round
		end
		
		
		# positing setting method similar to Camera#look_at
		def position=(pos)
			@components[:physics].right_hand_on_red(effective_local_origin, pos)
			
			
			@dirty = Gosu.milliseconds
			@position = pos
		end
		
		def position
			@components[:physics].body.local2world(effective_local_origin)
		end
		
		
		
		
		private
		
		def effective_local_origin
			edge = @components[:physics].shape.edge CP::Vec2.new(0,-1)
			center_of_edge = CP::Vec2.midpoint(*edge)
			
			return center_of_edge
		end
	end
end



end