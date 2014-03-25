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
	require File.expand_path File.join '.', 'lib', 'ThoughtTrace', 'serialization', 'rakefile.rb'
end





task :default => :run

# run the program
task :run => ['serialization:build', :load_dependencies, :load_main] do
	# filepath = ARGV[0]
	# filename ||= "default.yml"
	# raise "No file path specified" unless filepath
	
	# x = Window.new filepath
	x = Window.new
	x.show
	x.on_shutdown
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
				'./monkey_patches',
				
				'./utilities/meta',
				'./utilities/font',
				
				'./space',
				
				# require_all seems to snip the Class#inherited callback.
				# wait, but only for recursive add or something?
				# one directory at a time seems to be fine...
				# './entities'
				'./entities/share/',
				'./entities/actions/',
				'./entities/components/',
				'./entities/',
				
				'./cameras/camera',
				
				
				# './input_system'
					'./input_system/human_action',
					
					'./input_system/action_stash',
					'./input_system/action_selector',
					
					'./input_system/input_abstraction',
					# './input_system/human_actions' # currently empty folder
					
					'./input_system/input_manager',
				
				
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