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
					
					
					unless transforms[:each_line].empty?
						Parser.transform_each_line(body_lines, transforms[:each_line])
					end
					
					unless transforms[:whole_array].empty?
						Parser.transform_whole_array(body_lines, transforms[:whole_array])
					end
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