module ThoughtTrace
	# timer that splits time into two phases (a 'tick' and a 'tock')
	class TickTockTimer < Timer
		def update
			now = now()
			time = elapsed_time(@start_time, now)
			puts time
			
			
			
			# divide time into 2 phases, where each phase has length dt
			dt = @target_time
			if time % (dt*2) < dt
				@tick_block.call
			else
				@tock_block.call
			end
			
			
			
			
			if @start_time > now
				# on timer wraparound
				remainder = time % @target_time
				@start_time = now + remainder
			end
		end
		
		def wait(time, tick:nil, tock:nil)
			@start_time = now()
			@target_time = time
			
			@tick_block = tick
			@tock_block = tock
		end
		
		
		def reset
			@start_time = now()
		end
		
		def dt
			@target_time
		end
		
		def dt=(arg)
			@target_time = arg
		end
	end



end