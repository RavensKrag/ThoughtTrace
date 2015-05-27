module ThoughtTrace
	class << self
		# Remap a value from the input range, to the output range.
		# If no output range is specified, will map onto the normalized range aka [0..1]
		
		def range_remap(input_range:0..255, output_range:0.0..1.0, value:0)
			src  = input_range
			dest = output_range
			
			# src: http://stackoverflow.com/questions/3451553/value-remapping
			# low2 + (value - low1) * (high2 - low2) / (high1 - low1)
			return dest.first + (value - src.first) * (dest.last - dest.first) / (src.last - src.first)
		end
	end
end