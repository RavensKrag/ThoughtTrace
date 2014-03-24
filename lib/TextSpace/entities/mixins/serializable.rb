module ThoughtTrace
	module Serializable


def foo
	
end

# Figure out Array#pack pack string based on object types
def pack(*args)
	pack_string = ""
	
	args.each do |data|
		pack_string <<	if data.is_a? Float
							# double-precision, network (big-endian) byte order
							'G'
						elsif data.is_a? Integer
							case data.size
								# size starts at 8 and increases in steps of 4
								when 8
								when 12
								when 16
								when 32
							end
								
						elsif data.is_a? String
							
						end
	end
end


	
end
end