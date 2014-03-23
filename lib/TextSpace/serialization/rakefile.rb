require 'rubygems'

require 'rake/clean'




# ascii fonts from http://patorjk.com/software/taag/#p=display&f=Graceful&t=Constants
# (could possibly just query that, actually)


#  ____  ____  ____  _  _  ____ 
# / ___)(  __)(_  _)/ )( \(  _ \
# \___ \ ) _)   )(  ) \/ ( ) __/
# (____/(____) (__) \____/(__)  
path_to_this_file = File.expand_path '..', __FILE__
Dir.chdir path_to_this_file

require 'require_all'
require_all './build_system'



#   ___  __   __ _  ____  __  ___ 
#  / __)/  \ (  ( \(  __)(  )/ __)
# ( (__(  O )/    / ) _)  )(( (_ \
#  \___)\__/ \_)__)(__)  (__)\___/
# load and dump files really just control moving data in and out of an array
# the actual disk operation is handled separately
# so serialization methods can be changed as necessary
CONFIG = {
	:read  => ['./templates/unpack.rb', '_unpack.rb'],
	:write => ['./templates/pack.rb', '_pack.rb']
}

SOURCE_DIRECTORY = './source'
OUTPUT_DIRECTORY = './compiled_files'



#  _  _  ____  ____  _  _   __  ____  ____ 
# ( \/ )(  __)(_  _)/ )( \ /  \(    \/ ___)
# / \/ \ ) _)   )(  ) __ ((  O )) D (\___ \
# \_)(_/(____) (__) \_)(_/ \__/(____/(____/
def read_file_to_array(filepath)
	file = File.open(filepath, 'r')
	lines = file.readlines
	file.close
	
	return lines
end

def find_and_replace(lines_as_array, regex, replacement)
	return if replacement.nil?
	
	lines_as_array.each do |line|
		line.gsub! regex, replacement
	end
end



class Array
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
	
	def indent_each_line(indent_sequence="\t")
		return self.collect{ |line|	"#{indent_sequence}#{line}" }
	end
	
	# in place version of above method
	def indent_each_line!(indent_sequence="\t")
		return self.collect!{ |line|	"#{indent_sequence}#{line}" }
	end
end



# extract the BODY definition from the source
def extract_body(source_lines)
	# start on line that says BODY and then find the code between the curly braces
	find_between_curly_braces = %r{
	  (?<re>
	    \{
	      (?:
	        (?> [^\{\}]+ )
	        |
	        \g<re>
	      )*
	    \}
	  )
	}x
	
	# same code from 'basic replacement section'
	# or rather, similar
	# searching for the index in the source_lines array where the line is found
	# rather than the line itself
	marker = 'BODY'
	index = source_lines.index_of_line_containing marker
	
	# all lines as one string
	# starting from the line where BODY is declared, until the end
	source_blob = source_lines[index..-1].join
	
	# extract desired code from the blob
	body = source_blob.scan(find_between_curly_braces)
	body = body.first.first # get the string out of the nested array structure
	
	# strip the brace characters off the found string
	# (take off the first and last characters)
	body = body[1..-2]
	
	return body
end

# Extract the BODY transform information from the template
# 
# find BODY line in template, and figure out what the transforms are
# take the transforms off the line,
# but leave the BODY marker in place, so you know where the body should go
def extract_transforms(template_lines)
	# take the transform declarations off the original line
	# "BODY.one.two.three" -> "BODY", ["one", "two", "three"]
	# (preserve any indentation on the original line)
	marker = 'BODY'
	index = template_lines.index_of_line_containing marker
	
	line = template_lines[index]
	
	
	line.chomp! # strip newline so it doesn't end up in the parts array
		parts = line.split('.')
	line = parts.shift + "\n" # reintroduce the newline that was stripped
	
	
	template_lines[index] = line
	
	
	transforms = parts
	
	return transforms
end



#  ____  __   ____  __ _  ____ 
# (_  _)/ _\ / ___)(  / )/ ___)
#   )( /    \\___ \ )  ( \___ \
#  (__)\_/\_/(____/(__\_)(____/

task :default => :build
task :build => :data_packing



CLEAN.include OUTPUT_DIRECTORY
# CLOBBER.include


task :data_packing do
	# Examine the files in SOURCE_DIRECTORY
	# combining that data with the data from templates/
	# generate files that will perform load and dump
	# place generated files into OUTPUT_DIRECTORY
	
	Dir["#{SOURCE_DIRECTORY}/*.rb"].each do |path_to_source|
		name = path_to_source.strip_extension
		
		
		CONFIG.each do |config_name, data|
			template_file, suffix = data
			
			
			# =================================
			# =========== Procedure ===========
			# =================================
			# load file
			# perform necessary operations
			# and then perform one write pass
			# =================================
			
			
			# --- load files into memory
			# copy entire file into memory for editing
				# source file
				# NOTE: this will currently open the source file twice:
				# once for the load pass, and again for dump pass
				source_lines = read_file_to_array(path_to_source)
				
				# template file
				template_lines = read_file_to_array(template_file)
			
			# --- filling out fields
			# substitute CLASS_NAME for proper name of class
			# 	name should be derived from name of source file
				find_and_replace(template_lines, /CLASS_NAME/, name)
			
			
			# --- basic replacement
			# substitute ARGS and OBJECT with proper values
			# 	requires parsing of the source for ARGS and OBJECT values
				args, obj = %w[ARGS OBJECT].collect do |marker|
					source_lines.find_line_containing(marker).extract_value_list(marker)
				end
				
				find_and_replace(template_lines, /ARGS/, args)
				find_and_replace(template_lines, /OBJECT/, obj)
				
			
			# --- body compilation
			# perform necessary transforms on BODY
			# 	must extract BODY code from source file,
			# 	and then apply transforms defined in template
				# extract body
					body = extract_body(source_lines)
					
				# transform body as necessary
					# split into separate lines
					body_lines = body.split("\n")
						
						# remove leading and trailing empty lines
						body_lines = body_lines.strip_blank_lines
						
						
						# =========================================
						# Transform body as requested in template
						# =========================================
						transforms = extract_transforms(template_lines)
						
						# p transforms # DEBUG OUT
							
							
						# actually apply transforms if any have been found
						unless transforms.empty?
							body_lines.collect! do |line|
								line = TextSpace::StringWrapper.new line
								
								transforms.inject(line) do |line, method|
									unless line.respond_to? method
										raise "Build failed. Undefined transform '#{method}'"
									end
									
									line.send method
								end
								
								# puts line.string # DEBUG OUT
								
								
								line.string # <-- this is the collected value
							end
						end
							
						# =========================================
						
						
						
						# indent each line with one tab
						body_lines.indent_each_line!
						# (except not the first line - that should have no leading whitespace)
						body_lines[0].lstrip!
						
						
						
					# rejoin body as one text blob
					# (preparation for gsub!)
					body = body_lines.join("\n")
				
				# place body code into proper spot in template
					find_and_replace(template_lines, /BODY/, body)
					
			
			
			# --- write compiled file
			# write the edited lines in template_lines into the proper output file
				# create the output directory if necessary
				Dir.mkdir OUTPUT_DIRECTORY unless File.exists? OUTPUT_DIRECTORY
				
				
				output_filename = "#{name}#{suffix}"
				filepath = File.expand_path File.join(OUTPUT_DIRECTORY, output_filename)
				
				File.open(filepath, 'w') do |out|
					template_lines.each{ |line| out.puts line }
				end
		end
	end
end