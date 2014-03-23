class Array
	def find_and_replace(regex, replacement)
		return if replacement.nil?
		
		self.each do |line|
			line.gsub! regex, replacement
		end
	end
	
	
	
	def find_line_containing(marker)
		return self.find{|line| line.include? marker}
	end
	
	def index_of_line_containing(marker)
		# same code from 'basic replacement section'
		# or rather, similar
		# searching for the index in the array where the line is found
		# rather than the line itself
		
		return self.index{|line| line.include? marker}
	end
	
	
	
	
	# remove leading and trailing empty lines
	def strip_blank_lines
		first_content_line = self.index{ |line| line != "" }
		last_content_line = self.rindex{ |line| line != "" }
		return self[first_content_line..last_content_line]
	end
	
	# in-place version of above method
	def strip_blank_lines!
		first_content_line = self.index{ |line| line != "" }
		last_content_line = self.rindex{ |line| line != "" }
		
		self[0..(first_content_line-1)] = nil # remove from start to first good line
		self[(last_content_line+1)..-1] = nil # remove from last good line to end
		self.compact! # remove the 'nil's from the last two statements
		
		return self
	end
	
	def indent_each_line(indent_sequence="\t")
		return self.collect{ |line|	"#{indent_sequence}#{line}" }
	end
	
	# in place version of above method
	def indent_each_line!(indent_sequence="\t")
		return self.collect!{ |line|	"#{indent_sequence}#{line}" }
	end
end