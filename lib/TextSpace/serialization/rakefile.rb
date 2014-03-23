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



module Parser
	MATCHING_CURLY_BRACES = %r{
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
	
	class << self
	
	# extract the BODY definition from the source
	def extract_body(source_lines)
		# start on line that says BODY and then find the code between the curly braces
		
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
		body = source_blob.scan(MATCHING_CURLY_BRACES)
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
		marker = 'BODY'
		
		# TODO: store 'curly-brace finding' part of regex in variable, because it ends up being used at least twice
		
		expression = /\s*#{marker}\s*\{\s*/ # '   BODY { ' <-- any amount of whitespace anywhere
		
			
		index = template_lines.index_of_line_containing marker
		line = template_lines[index]
		
		
		transforms = nil
		if line.starts_with? expression
		# --- curly-brace (multi-line) format
			# statements listed between curly braces, one statement per line
			# - these statements should be applied to every line in the BODY
			# 
			# additional statements listed as in one-line format, after the ending brace
			# - these statements apply to the Array of lines as a whole
			
			# find the first line that contains a closing curly brace
			# which comes after the line with the body marker
			# the index of that line, is the ending index for the scan
			
			stop_index =	(index..(template_lines.size-1)).find do |i|
								template_lines[i].include? '}'
							end
			
			
			# assuming the 'first line' never contains transforms
			# (maybe that's weird considering how the last line could? I don't think so...)
			lines = template_lines[(index+1)..stop_index]
			line_transforms = lines[0..-2] # last line may or may not be (is '}' on a new line?)
			
			
			# figure out if there's a each-line transform on the last line or not
			parts = lines.last.split('}')
			if parts.size != 1
				p = parts.shift # take off the first element (pop is the last element)
				
				line_transforms << p unless p =~ /^\s*$/ # s is whitespace only
			end
			
			
			raise "should only be one element left in parts" unless parts.size == 1
			array_transforms_string = parts.first
			
			
			
			
			# --- refine each-line transforms
			line_transforms.each do |line|
				line.strip!
			end
			
			transforms = line_transforms
			
			# --- refine array-wide transforms
			array_transforms = array_transforms_string.split('.')
			array_transforms.shift # first element is always empty string; discard it
			
			
			
			# --- clean up ---
			# take the opening curly-brace off, along with any whitespace around it
			# (leaves the indentation intact, though)
			template_lines[index].sub! /\s*\{\s*/, ''
			
			# remove lines associated with transforms
			template_lines[(index+1)..stop_index] = nil
			template_lines.compact!
		else
		# --- one-line format
			# take the transform declarations off the original line
			# "BODY.one.two.three" -> "BODY", ["one", "two", "three"]
			# (preserve any indentation on the original line)
			
			line.chomp! # strip newline so it doesn't end up in the parts array
				parts = line.split('.')
			line = parts.shift + "\n" # reintroduce the newline that was stripped
			
			
			template_lines[index] = line
			
			
			transforms = parts
		end
		
		
		
		return transforms
	end

	def apply_transforms(body_lines, transforms)
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
	
	
	end
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
				template_lines.find_and_replace(/CLASS_NAME/, name)
			
			
			# --- basic replacement
			# substitute ARGS and OBJECT with proper values
			# 	requires parsing of the source for ARGS and OBJECT values
				args, obj = %w[ARGS OBJECT].collect do |marker|
					source_lines.find_line_containing(marker).extract_value_list(marker)
				end
				
				template_lines.find_and_replace(/ARGS/, args)
				template_lines.find_and_replace(/OBJECT/, obj)
				
			
			# --- body compilation
			# perform necessary transforms on BODY
			# 	must extract BODY code from source file,
			# 	and then apply transforms defined in template
				# extract body
				body = Parser.extract_body(source_lines)
				
				
				# transform body as necessary
				body = body.split_and_rejoin do |body_lines|
					body_lines.strip_blank_lines!
					
					
					# =========================================
					# Transform body as requested in template
					# =========================================
					transforms = Parser.extract_transforms(template_lines)
					
					Parser.apply_transforms(body_lines, transforms) unless transforms.empty?
					# =========================================
					
					
					
					body_lines.indent_each_line!
					# (except not the first line - that should have no leading whitespace)
					body_lines[0].lstrip!
				end
					
				
				# place body code into proper spot in template
				template_lines.find_and_replace(/BODY/, body)
					
			
			
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