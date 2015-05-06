# Allow for easy changes between different sizes of the same font face

module ThoughtTrace
	class Font
		attr_reader :i
		attr_reader :name
		
		class << self
			def new(name)
				# Not triggering on load, because loading somehow circumvents the call to new?
				
				@fonts ||= Hash.new
				if @fonts[name]
					# Font already initialized
					return @fonts[name]
				else
					@fonts[name] = super(name)
					return @fonts[name]
				end
			end
		end
		
		# TODO: While scaling, make font using OpenGL scaling, picking from cached sizes as appropriate.  When scaling ends, the font should lock to the exact size, rendered as the font engine specifies.
		
		def initialize(name)
			@@fonts ||= Hash.new
			if @@fonts[name]
				# Font already initialized
				# Point to existing values instead of making more
				
				# NOTE: Current method only copies the underlying values, not the Font objects themselves, which means that this object is prone to memory leaks.
				[:@name, :@font_cache].each do |var|
					instance_variable_set var, @@fonts[name].instance_variable_get(var)
				end
			else
				# Set up normally
				@name = name
				
				generate_font_cache name
				
				@@fonts[name] = self
			end
		end
		
		def generate_font_cache(name)
			@font_cache = []
			
			# TODO: Consider using some other sequence than Fibonacci. Just used fib because it was easy
			fib = Enumerator.new do |y|
				a, b = [1, 1]
				
				loop do
					y.yield a
					
					x = a + b
					a = b
					b = x
				end
			end
			
			pow2 = Enumerator.new do |y|
				x = 1
				
				loop do
					y.yield x
					
					x = x << 1
				end
			end
			
			
			# TODO: Consider removing font sizes < 5
			# Really small pixel size fonts aren't noticeably different, but the extra font objects will take up extra memory
			# Getting rid of < 5 will remove 1,2,3 == 3 items
			# Reduces number of fonts cached from 14 -> 11
			# That's about a 20% reduction
			heights = fib.first(14).uniq # get rid of the duplicate 1s at the start
			# heights -= (1..10).to_a
			# heights += (1..10).to_a
			# heights.sort!
			# heights = pow2.first(11)
			# heights = [10,30,40]
			puts "cached font sizes: #{heights.inspect}"
			puts "\n\n"
			
			
			# TODO: Consider caching font sizes on demand.
			# would need a way to track what font objects are active, as to get a better sense of what sizes need to be available
			# don't want to duplicate pointers, as that complicates GC
			# should probably just have a read-only reference to the text objects in the Space
			heights.each do |height|
				@font_cache << Gosu::Font.new($window, name, height)
			end
		end
		
		def draw(text, height, x,y,z=0, color=0xffffffff)
			# NOTE: Font should provide the same interface as Gosu::Font, so rounding to pixel-perfect outputs happens in Text instead
			height = height.to_i
			
			
			# ---Find the font in the cache
			f = find_font_object(height)
			
			# ---Calculate font scaling
			# @scale * font.height == @height
			scale = height / f.height.to_f
			
			f.draw(text, x,y,z, scale, scale, color)
		end
		
		def width(text, height)
			# NOTE: should be integers for input, and integers for final output
			# TODO: make sure that height is always an integer
			height = height.to_i
			
			
			
			f = find_font_object(height)
			
			scale = height / f.height.to_f
			
			return (f.text_width(text) * scale).round
		end
		
		
		
		
		def inspect
			"#{@name}<id:#{object_id}-#{@font_cache.object_id}>"
		end
		
		
		
		private
		
		def find_font_object(height)
			i = @font_cache.index {|f| f.height >= height }
			i ||= @font_cache.size-1
			
			# $window.debug_puts i
			
			return @font_cache[i]
		end
	end
end