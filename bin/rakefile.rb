require 'rubygems'

require 'rake'
require 'rake/clean'

# -- file hierarchy --
		# ROOT
		# 	this directory
		# 		this file

# Must expand '..' shortcut into a proper path. But that results in a shorter string.
PATH_TO_ROOT = File.expand_path '../..', __FILE__

Dir.chdir PATH_TO_ROOT do
	# require File.expand_path File.join '.', 'lib', 'ThoughtTrace', 'serialization', 'rakefile.rb'
end





task :default => :run

# run the program
task :run => [:build_serialization_system, :load_dependencies, :load_main] do
	# filepath = ARGV[0]
	# filename ||= "default.yml"
	# raise "No file path specified" unless filepath
	
	x = Window.new './data/input_sketch'
	x.show
	x.on_shutdown
end

task :build_serialization_system do
	path = File.join PATH_TO_ROOT, 'bin'
	Dir.chdir path do
		system "object-packer.rb"
	end
end

task :load_dependencies do
	require 'gosu'
	require 'gl'
	
	require 'DIS'
	
	require 'chipmunk'
	require 'require_all'
	
	
	# Doing it this way obfuscates what is a directory, and what is a file,
	# but it makes handling loading files in various directories
	# (especially directories that are not children of the current directory)
	# much easier to manage and understand.
	
	full_path = File.join PATH_TO_ROOT, "lib", "ThoughtTrace"
	
	Dir.chdir full_path do
		require './utilities/performance_timer'
		
		Metrics::Timer.new "load scripts" do
		
			[
				'./utilities/meta',
				
				'./monkey_patches',
				
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
				'./constraints',
				'./groups',
				
				'./space',
				
				
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
				
				
				# serialization
				'./serialization/compiled_files'
			
			
			
			].each do |path|
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

task :load_main do
	require './main'
end