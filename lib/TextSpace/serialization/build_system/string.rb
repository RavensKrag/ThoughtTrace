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
