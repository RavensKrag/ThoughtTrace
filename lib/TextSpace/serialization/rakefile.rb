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
LOAD_FILE_SUFFIX = '_load.rb'
DUMP_FILE_SUFFIX = '_dump.rb'

SOURCE_DIRECTORY = './source'
OUTPUT_DIRECTORY = './compiled_files'



#  ____  __   ____  __ _  ____ 
# (_  _)/ _\ / ___)(  / )/ ___)
#   )( /    \\___ \ )  ( \___ \
#  (__)\_/\_/(____/(__\_)(____/

# source files are 'foo.rb' built files are 'foo_reverse.rb'
task :default => :build




CLEAN.include OUTPUT_DIRECTORY
# CLOBBER.include


task :build do
	# Examine the files in SOURCE_DIRECTORY
	# combining that data with the data from templates/
	# generate files that will perform load and dump
	# place generated files into OUTPUT_DIRECTORY
	
	Dir["#{SOURCE_DIRECTORY}/*.rb"].each do |path_to_source|
		name = path_to_source.strip_extension
		
		config = {
			:load => ['./templates/load.rb', LOAD_FILE_SUFFIX],
			:dump => ['./templates/dump.rb', DUMP_FILE_SUFFIX]
		}
		config.each do |config_name, data|
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
				source = File.open(path_to_source, 'r')
				source_lines = source.readlines
				source.close
				
				# template file
				template = File.open(template_file, 'r')
				template_lines = template.readlines
				template.close
			
			
			# --- filling out fields
			# substitute CLASS_NAME for proper name of class
			# 	name should be derived from name of source file
				template_lines.each do |line|
					line.gsub! /CLASS_NAME/, name
				end
			
			
			# --- basic replacement
			# substitute ARGS and OBJECT with proper values
			# 	requires parsing of the source for ARGS and OBJECT values
				args, obj = %w[ARGS OBJECT].collect do |marker|
					source_lines.find{|line| line.include? marker}.foo(marker)
				end
				
				
				template_lines.each do |line|
					line.gsub! /ARGS/, args if args
					line.gsub! /OBJECT/, obj if obj
				end
				
			
			# --- body compilation
			# perform necessary transforms on BODY
			# 	must extract BODY code from source file,
			# 	and then apply transforms defined in template
				# extract body
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
					index = source_lines.index{|line| line.include? marker}
					
					# all lines as one string
					# starting from the line where BODY is declared, until the end
					source_blob = source_lines[index..-1].join
					
					# extract desired code from the blob
					body = source_blob.scan(find_between_curly_braces)
					body = body.first.first # get the string out of the nested array structure
					
					# strip the brace characters off the found string
					# (take off the first and last characters)
					body = body[1..-2]
					
				# transform body as necessary
					# split into separate lines
					body_lines = body.split("\n")
						
						
						
					# rejoin body as one text blob
					# (preparation for gsub!)
					body = body_lines.join("\n")
				
				# place body code into proper spot in template
					template_lines.each do |line|
						line.gsub! /BODY/, body
					end
			
			
			# --- write compiled file
			# write the edited lines in template_lines into the proper output file
				output_filename = "#{name}#{suffix}"
				filepath = File.expand_path File.join(OUTPUT_DIRECTORY, output_filename)
				
				File.open(filepath, 'w') do |out|
					template_lines.each{ |line| out.puts line }
				end
		end
	end
end