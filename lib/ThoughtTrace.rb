# This is the file that will be loaded when using `require`
# thus, this file should be used to load up all the dependencies.
# Think of this like a header file.


module ThoughtTrace
# define this stuff here, just for namespacing purposes
# don't want to overwrite some other symbols on accident


PATH_TO_ROOT = File.expand_path '../..', __FILE__


class << self

def load_dependencies(library_path, dependency_list)
	# Doing it this way obfuscates what is a directory, and what is a file,
	# but it makes handling loading files in various directories
	# (especially directories that are not children of the current directory)
	# much easier to manage and understand.
	Dir.chdir library_path do
		Metrics::Timer.new "load scripts" do
			dependency_list.each do |path|
				begin
					# if it's a path, require_all
					# if it's a file, require
					# ---------------------------
					if File.directory? path
						# puts "LOAD DIR: #{path}"
						require_all path
					# TODO: Figure out why File.file? doesn't work sans extensions like require
					# elsif File.file? path
					else
						# puts "LOAD FILE: #{path}"
						require path
					end
				rescue LoadError => e
					puts "LOAD ERROR: Failed to load #{path}"
					
					raise e
				end
			end
		
		end
	end
end


end
end











require 'gosu'
require 'gl'

require 'DIS'

require 'chipmunk'
require 'require_all'


library_root = File.join ThoughtTrace::PATH_TO_ROOT, "lib", "ThoughtTrace"
Dir.chdir library_root do
	require './utilities/performance_timer'
end


dependency_list = [
	'./utilities/meta',
	
	'./monkey_patches',
	
	'./drawing',
	
	'./utilities/font',
	'./style',
	
	
	# require_all seems to snip the Class#inherited callback.
	# wait, but only for recursive add or something?
	# one directory at a time seems to be fine...
	# './entities'
	'./entities/share/',
	'./entities/components/',
	'./entities/',
	
	'./queries',
	'./groups',
	
	# './space',
		'./space/layers',
		'./space/queries',
		# './space/serialization',
		'./space/space',
	
	
	'./constraint_system/',
	
	
	'./cameras/camera',
	
	
	# new actions
	'./actions/header',
	
	
	'./cloning',
	
	
	# './input_system'
		'./input_system/old/action_stash',
		
		'./input_system/button_event',
		'./input_system/button_parser',
		'./input_system/accelerator_parser',
		'./input_system/mouse',
		
		'./input_system/action_factory',
		'./input_system/mouse_input_system',
		'./input_system/camera_controller',
		
		'./input_system/text_input',
		
		'./input_system/input_manager',
		
		'./input_system/custom_events',
	
	
	# document format
	'./document',
	
	# serialization
	'./serialization/compiled_files',
	'./serialization/manual_serialization',
	'./serialization/yaml'
]
ThoughtTrace.load_dependencies(library_root, dependency_list)
