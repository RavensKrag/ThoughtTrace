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
			@start_time = nil
		end
		
		# control flashing of caret
		def update
			# if caret has been moved recently, don't blink
			# otherwise, blink based on which of two time phases is active
			
			if @dirty
				# reset accumulated time, and then clear dirty flag
				@start_time = nil
				@dirty = false
			end
			
			
			
			
			if @start_time.nil?
				@start_time = Gosu.milliseconds
			end
			
			# time = elapsed_time(@start_time, now())
			time = Gosu.milliseconds - @start_time
			# puts time
			
			
			# divide time into 2 phases, where each phase has length @dt
			if time % (@dt*2) < @dt
				@visible = true
			else
				@visible = false
			end
			
			
			
			# need to bump up the start time periodically,
			# otherwise the wrapping timer thing will get really really weird
			if Gosu.milliseconds < @start_time
				# wrap around has occured.
				# now you need to compensate for it
				# plan: set start to current time + compensation to line up with current cycle
				
				
				# ok this delta calculation is wrong b/c wrap around but w/e
				# (will eventually use the same 'takes wrap around into account' time delta code everywhere)
				delta = Gosu.milliseconds - @start_time
				
				
				remainder = delta % @dt
				@start_time = Gosu.milliseconds + remainder
				
				# NOTE: assuming that Gosu.milliseconds only gets updated once per tick
			end
			
			
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