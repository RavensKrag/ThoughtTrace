require File.expand_path '../../../utilities/serialization/serializable', __FILE__

# Allow for easy changes between different sizes of the same font face

module TextSpace
	class Font
		MINIMUM_HEIGHT = 5
		
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
			fib = ->(n) {
				return n if n < 2
				
				vals = [0, 1]
				(n-1+2).times do # extra two times because we're gonna take off the first two
					vals.push(vals[-1] + vals[-2]) 
				end
				
				# remove the first two values
				vals.shift
				vals.shift
				
				return vals
			}
			pow2 = ->(n) {
				vals = [1]
				(n-1).times do
					vals.push(vals[-1]*2)
				end
				
				return vals
			}
			
			# TODO: Consider removing font sizes < 5
			# Really small pixel size fonts aren't noticeably different, but the extra font objects will take up extra memory
			# Getting rid of < 5 will remove 1,2,3 == 3 items
			# Reduces number of fonts cached from 14 -> 11
			# That's about a 20% reduction
			heights = fib[14]
			# heights -= (1..10).to_a
			# heights += (1..10).to_a
			# heights.sort!
			# heights = pow2[11]
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
			# --Prevent out of bounds
			height = MINIMUM_HEIGHT if height < MINIMUM_HEIGHT
			
			# ---Find the font in the cache
			f = find_font_object(height)
			
			# ---Calculate font scaling
			# @scale * font.height == @height
			scale = height / f.height.to_f
			
			f.draw(text, x,y,z, scale, scale, color)
		end
		
		def width(text, height)
			height = MINIMUM_HEIGHT if height < MINIMUM_HEIGHT
			
			f = find_font_object(height)
			scale = height / f.height.to_f
			
			return f.text_width(text) * scale
		end
		
		
		
		
		include TextSpace::Serializable
		
		def init_with coder
			name = YAML.load(coder.scalar)
			initialize(name)
		end
		
		# TODO: Define #encode_with instead (maybe not because of how this object is saved...?)
		def to_string_representation
			@name.to_yaml
		end
		
		class << self
			def from_string_representation(string_representation)
				puts "YAML UP"
				name = YAML.load(string_representation)
				new(name)
			end
		end
		
		def inspect
			"#{@name}<id:#{object_id}-#{@font_cache.object_id}>"
		end
		
		
		
		private
		
		def find_font_object(height)
			i = @font_cache.index {|f| height <= f.height}
			i ||= @font_cache.size-1
			
			# $window.debug_puts i
			
			return @font_cache[i]
		end
	end
end