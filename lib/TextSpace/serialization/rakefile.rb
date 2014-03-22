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
	
	Dir["#{SOURCE_DIRECTORY}/*.rb"].each do |source|
		name = source.strip_extension
		
		config = {
			:load => ['./templates/load.rb', LOAD_FILE_SUFFIX],
			:dump => ['./templates/dump.rb', DUMP_FILE_SUFFIX]
		}
		config.each do |config_name, data|
			template_file, suffix = data
			
			
			# ACTIVE FILE HANDLES:
			# source    -----	raw source file
			
			
			# =================================
			# =========== Procedure ===========
			# =================================
			# load file
			# perform necessary operations
			# and then perform one write pass
			# =================================
			
			
			# --- load file into memory
			# copy entire template file into memory for editing
			template = File.open(template_file, 'r')
			lines = template.readlines
			template.close
			
			
			# --- filling out fields
			# substitute CLASS_NAME for proper name of class
			# 	name should be derived from name of source file
			
			
			
			# --- basic replacement
			# substitute ARGS and OBJECT with proper values
			# 	requires parsing of the source for ARGS and OBJECT values
			
			
			
			# --- body compilation
			# perform necessary transforms on BODY
			# 	must extract BODY code from source file,
			# 	and then apply transforms defined in template
			
			
			
			output_filename = "#{name}#{suffix}"
			filepath = File.expand_path File.join(OUTPUT_DIRECTORY, output_filename)
			
			# raise "no file found" unless File.exists? filepath
			
			File.open(filepath, 'w') do |out|
				# ACTIVE FILE HANDLES:
				# source    -----	raw source file
				# out       -----	compiled file
				
				
			end
		end
	end
end