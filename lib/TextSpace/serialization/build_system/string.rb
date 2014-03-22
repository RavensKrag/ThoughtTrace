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
end
