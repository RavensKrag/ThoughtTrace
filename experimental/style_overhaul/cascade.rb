# Establishes a hierarchy of Styles
# 
# style properties can be queried though this object
# as if you were polling one Style
class Cascade
	def initialize
		@styles = Array.new
		
		@styles << StyleObject.new
		# every Cascade initializes with a "primary" style
	end
	
	def primary
		@styles.first
	end
	
	
	
	# read from entire cascade
	def read(property)
		# find the first style object in the cascade order which has the desired property
		style = @styles.each.find{ |style| style.has_property? property }
		
		raise "Could not find any styles in this Cascade with that property" unless style
		
		return style[property]
	end
	
	# write to primary style
	def write(property, value)
		self.primary[property] = value
	end
	
	# place a given style in the specified index
	def socket(index, style)
		# do not allow socketing into index 0, the position of the "primary" style
		# that style will always persist at that location
		# (at least, in the abstracted model of things.)
		# (objects are really created / destroyed on load / dump)
		
		raise IndexError, "Not allowed to change the primary style"   if index == 0
		raise IndexError, "Indices must be positive natural numbers." if index < 0
		
		warn "Overwriting existing style. Style data may be lost." unless @styles[index].nil?
		
		@styles[index] = style
	end
	
	# remove a style object from the specified index
	# returns the Style which can just been removed
	# will return 'nil' if the index is beyond the current end of the list
	def unsocket(index)
		raise IndexError, "Not allowed to change the primary style"   if index == 0
		raise IndexError, "Indices must be positive natural numbers." if index < 0
		
		style = @styles.delete_at index
		
		return style
	end
	
	# iterate through all available style objects
	def each_style(&block) 
		
	end
	
	# move style from one index to another
	# If you specify a destination that is out of range,
	# ie: larger than the maximum index, or smaller than the minimum index,
	# then the style will be moved to the maximum extent it can be moved.
	# (Behavior thus mimics #move_up and #move_down)
	def move(from:nil, to:nil)
		raise ArgumentError, "Must specify a source index using 'from:'"     unless from
		raise ArgumentError, "Must specify a destination index using 'to:'"  unless to
		
		@styles.insert(to, @styles[from])
		@styles.delete_at(from)
		
		return self
	end
	
	# move style at specified index one position up
	# has no effect if item is already at the top of the list
	# (low index is "higher", ie earlier in the list is higher priority)
	def move_up(index)
		
	end
	
	# move style at specified index one position down
	# has no effect if the item is already at the bottom of the list
	# (high index is "lower", ie later in the list is lower priority)
	def move_down(index)
		
	end
	
end