module Gosu


class Color
	def to_s
		"0x"+self.pack.to_s(16)
	end
	
	def inspect
		a,r,g,b = [self.alpha, self.red, self.green, self.blue]
		"#<#{self.class}:#{object_space_id_string} alpha:#{a} red:#{r} green:#{g} blue:#{b}>"
	end
	
	
	def ==(other)
		return false unless other.is_a? self.class
		
		[:alpha, :red, :green, :blue].all?{ |x| self.send(x) == other.send(x) }
	end
	
	
	
	
	
	
	# TODO: use proper alpha blending for these methods, instead of just treating the Alpha channel like any other channel
	
	def -(other)
		transform(other) do |this, input|
			this.each_with_index.collect do |channel, i|
				[channel - input[i]].max
			end
		end
	end
	
	def +(other)
		transform(other) do |this, input|
			this.each_with_index.collect do |channel, i|
				channel + input[i]
			end
		end
	end
	
	def *(other)
		transform(other) do |this, input|
			this.each_with_index.collect do |channel, i|
				channel * input[i]
			end
		end
	end
	
	
	private
	
	# ----
	# conversions between 0xff (255) max to 0..1 floating point representation
	
	def float_to_hex(channel)
		(channel * 0xff).to_i
	end
	
	def hex_to_float(channel)
		channel / 0xff.to_f
	end
	# ----
	
	
	def transform(other, &block)
		# split out the colors
		one = [self.alpha, self.red, self.green, self.blue]
		two = [other.alpha, other.red, other.green, other.blue]
		
		
		# convert to float
		[one, two].each{|color|  color.collect!{  |channel|  hex_to_float(channel)  } }
		
		# run actual transform
		color_data = block.call(one, two)
		
		# pack it into a hex number
		color_hex = 0x00
			color_data.each_with_index do |channel, i|
				color_hex = color_hex | float_to_hex(channel) << 8*(color_data.size-1-i)
			end
		
		# pack that hex number back into a Color object
		return Gosu::Color.unpack color_hex
	end
end



end