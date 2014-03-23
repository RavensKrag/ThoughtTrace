# monkey patches for String class
# holds things that are potentially useful outside of just the build system

class String
	def strip_extension
		# taken from StackExchange
		File.basename(self,File.extname(self))
	end
	
	# src: http://rosettacode.org/wiki/Strip_comments_from_a_string
	def strip_comment( markers = ['#',';'] )
		re = Regexp.union( markers ) # construct a regular expression which will match any of the markers
		if index = (self =~ re)
			self[0, index].rstrip      # slice the string where the regular expression matches, and return it.
		else
			rstrip
		end
	end
	
	
	# split lines into array entries
	# allow manipulation of the array inside a block
	# when the block closes, rejoin the array into one String again
	# (can't figure out how to do this in-place, so I'll just return a new string)
	
	# Make sure to perform all operations on the array in-place
	# (non-in-place operations will rebind the variable, which is not what you want)
	def split_and_rejoin(marker="\n", &block)
		lines_as_array = self.split(marker)
		
			block.call lines_as_array
		
		output = lines_as_array.join(marker)
		
		return output
	end
	
	
	
	# If the string is of the form
		# KEYWORD a b c d
		# return the list of values, leaving the original string intact
	# return nil in all other cases
	def extract_value_list(keyword)
		line = self.clone
		
		line = line.strip_comment
		
		match = line.match(keyword)
		
		return nil unless match
		return nil unless match.begin(0) == 0 # beginning of the match with index 0
		
		
		parts = line.split
		parts.shift # eject the return statement, keep the rest of the line
		line = parts.join(', ')
		# puts line
		return line
	end
end
