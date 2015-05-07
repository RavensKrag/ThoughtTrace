module ThoughtTrace
	# reoccurring timer
	class PeriodicTimer < Timer
		def update
			now = now()
			time = elapsed_time(@start_time, now)
			puts time
			
			if time >= @target_time
				if @block
					@block.call
					
					if @start_time > now
						# on timer wraparound
						remainder = time % @target_time
						@start_time = now + remainder
					end
				end
			end
		end
	end



end