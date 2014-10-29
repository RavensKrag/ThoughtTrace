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
	require './lib/ThoughtTrace'
	# require File.expand_path File.join '.', 'lib', 'ThoughtTrace', 'serialization', 'rakefile.rb'
end




task :default => :run

# run the program
task :run => [:build_serialization_system, :load_dependencies, :load_main] do
	# filepath = ARGV[0]
	# filename ||= "default.yml"
	# raise "No file path specified" unless filepath
	
	x = Window.new './data/test'
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
	
end

task :load_main do
	require './main'
end


task :document_test => [:build_serialization_system, :load_dependencies] do
	path = File.join(PATH_TO_ROOT, 'experimental', 'document_format')
	Dir.chdir path do
		require './test'
	end
end