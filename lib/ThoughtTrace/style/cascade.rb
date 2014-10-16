module ThoughtTrace
	module Style


# Establishes a hierarchy of Styles
# 
# style properties can be queried though this object
# as if you were polling one Style
class Cascade
	def initialize
		@styles = Array.new
		
		@styles << StyleObject.new("primary")
		# every Cascade initializes with a "primary" style
	end
	
	def ==(other)
		return (
			other.size == self.size
			other.all?{ |style| @styles.include? style}
		)
	end
	
	
	def name
		"cascade #{object_space_id_string}"
	end
	
	
	# read from entire cascade
	def [](property)
		# find the first style object in the cascade order which has the desired property
		style = @styles.each.find{ |style| style.has_property? property }
		
		raise "Could not find any styles in this Cascade with that property" unless style
		
		return style[property]
	end
	
	# write to primary style
	def []=(property, value)
		self.primary_style[property] = value
		
		return self
	end
	
	
	def has_property?(property)
		!self[property].nil?
	end
	
	
	
	
	
	def primary_style
		@styles.first
	end
	
	
	# the number of styles currently registered within this cascade
	def size
		return @styles.size
	end
	
	
	
	
	
	# place a given style in the specified index
	def socket(index, style)
		# do not allow socketing into index 0, the position of the "primary" style
		# that style will always persist at that location
		# (at least, in the abstracted model of things.)
		# (objects are really created / destroyed on load / dump)
		
		raise IndexError, "Not allowed to change the primary style"   if index == 0
		raise IndexError, "Indices must be positive natural numbers." if index < 0
		
		# warn if there is an attempt to put a new style into an already occupied slot
		# if you try to put an equivalent object into the slot, no big deal, no warning
		stored_style = @styles[index]
		if !stored_style.nil? and style != stored_style
			name = style.name
			name = "<NO NAME>" if name == ""
			
			id = self.object_space_id_string
			
			warn "Overwriting existing style '#{name}' in slot #{index} of cascade #{id}."
		end
		
		@styles[index] = style
		
		return self
	end
	
	# remove a style object from the specified index
	# returns the Style which can just been removed
	# will return 'nil' if the index is beyond the current end of the list
	def unsocket(index)
		raise IndexError, "Not allowed to remove the primary style"   if index == 0
		raise IndexError, "Indices must be positive natural numbers." if index < 0
		
		style = @styles.delete_at index
		
		return style
	end
	
	# retrieve the style object stored at the specified index
	def read_socket(index)
		return @styles[i]
	end
	
	# iterate through all available style objects
	def each(&block)
		# iterate and return self, or return an iterator
		if block
			@styles.each &block
			return self
		else
			return @styles.each
		end
	end
	
	alias :each_style :each
	
	include Enumerable
	# includes definition of #find
	
	
	# move style from one index to another
	# If you specify a destination that is out of range,
	# ie: larger than the maximum index, or smaller than the minimum index,
	# then the style will be moved to the maximum extent it can be moved.
	# (Behavior thus mimics #move_up and #move_down)
	def move(from:nil, to:nil)
		raise ArgumentError, "Must specify a source index using 'from:'"     unless from
		raise ArgumentError, "Must specify a destination index using 'to:'"  unless to
		
		if from >= @styles.size
			message = 
				if @styles.size == 1
					"Source index #{from} is too large. Only primary style present, and that can't be moved."
				else
					"Source index #{from} is too large. Maximum source index is #{@styles.size-1}."
				end
			
			raise IndexError, message
		end
		raise IndexError, "Source index #{from} does not contain a Style."  if @styles[from].nil?
		
		raise IndexError, "Not allowed to change the primary style"   if to == 0
		raise IndexError, "Indices must be positive natural numbers." if to < 0
		
		
		
		warn "Moving #{from} to #{to} will generate empty slots. Those slots will need to be filled before iterating with #each or similar." if to > @styles.size
		# trying to read through the cascade with empty slots
		# (nil values in array) will result in errors.
		
		
		
		@styles.insert(to, @styles[from])
		@styles.delete_at(from)
		
		return self
	end
	
	# move style at specified index one position up
	# has no effect if item is already at the top of the list
	# (low index is "higher", ie earlier in the list is higher priority)
	def move_up(index)
		raise ArgumentError, "Can not move the primary Style" if index == 0
		raise IndexError, "Indices must be positive natural numbers." if index < 0
		
		
		# can't be 0: can't move the primary style 
		# can't be 1: can't move the style at index 1 up, because it would displace the primary
		if index > 1
			src = index
			dst = index - 1
			
			swap(@styles, src, dst)
		end
	end
	
	# move style at specified index one position down
	# has no effect if the item is already at the bottom of the list
	# (high index is "lower", ie later in the list is lower priority)
	def move_down(index)
		raise ArgumentError, "Can not move the primary Style" if index == 0
		raise IndexError, "Indices must be positive natural numbers." if index < 0
		
		
		# can't move the final element in the list down any further
		if src == @styles.size-1
			src = index
			dst = index + 1
			
			swap(@styles, src, dst)
		end
	end
	
	
	
	private
	
	# swap the item at index 'src' with the item at index 'dst'
	def swap(list, src, dst)
		swap = list[dst]
		list[dst] = list[src]
		list[src] = swap
	end
end


end
end