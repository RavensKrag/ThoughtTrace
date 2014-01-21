# Measure how long it takes to complete the operation specified in the given block

module Metrics
	class Timer
		attr_reader :dt
		
		def initialize(task_name)
			@task_name = task_name
			
			
			timer_start = Gosu::milliseconds
			
			yield
			
			timer_end = Gosu::milliseconds
			@dt = timer_end - timer_start

			puts self.to_s
		end
		
		def to_s
			"#{@task_name} complete (#{@dt} ms)"
		end
	end
end

# API example
# Metrics::Timer.new "loading files" do
# 	puts "Doing some stuff here"
# end