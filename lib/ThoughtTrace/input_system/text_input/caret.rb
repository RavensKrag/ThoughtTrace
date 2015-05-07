module ThoughtTrace


class TextInput
	class Caret < ThoughtTrace::Rectangle
		def initialize(width)
			# some default height, doesn't really matter
			# the "real" height should always be set before the Caret is actually used
			height = 10
			
			super(width, height)
			
			@components[:style].edit(:default) do |s|
				s[:color] = Gosu::Color.argb(0xffaaaaaa)
			end
			
			
			
			dt = 800
			@visible = true
			@dirty = false
			
			
			@timer = ThoughtTrace::TickTockTimer.new
			@timer.wait(dt,
				tick: ->(){
					@visible = true
				},
				
				tock: ->(){
					@visible = false
				}
			)
		end
		
		# control flashing of caret
		def update
			# if caret has been moved recently, don't blink
			# otherwise, blink based on which of two time phases is active
			
			if @dirty
				# reset accumulated time, and then clear dirty flag
				# (should hit this branch the every time the caret is initially made visible, because the caret always has to be moved into a position before it's visible.)
				@timer.reset
				@dirty = false
			end
			
			
			@timer.update
			
			
			
			# NOTE: now you have two possibly overflowing timers: Gosu.milliseconds AND time
			# maybe if you have a proper elapsed time function that takes into account the wrap around for Gosu.milliseconds, then its ok?
			# note that the wrap around handling in Timer is ok, because it only fires one tick.
			# when you fire periodic events, things are different.
			# you need to reset the timer sometime, but I'm not sure when.
				# ok, now we're taking periodic wrap around into account, so it's ok
				# (well, the delta calculation is currently still wrong but w/e)
			
			
			
			# NOTE: I think because of the nil / setting @start_time gap, this timing mechanism will drift over time, getting ever so slightly increasingly further away from the real (or, 'ideal'?) measurement.
				# I don't think this problem is present in the current iteration of this code
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
			return if pos == self.position
			
			@components[:physics].right_hand_on_red(effective_local_origin, pos)
			
			@dirty = true
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